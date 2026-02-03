# Podcast Collections Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Turn `/podcast` into a collections landing page with category cards, and add `/podcast/collections/:slug` pages for filtered episode lists.

**Architecture:** Add slug to PodcastCategory, repurpose PodcastEpisodesController index as collections grid, add a new show action for filtered/all episode lists under `/podcast/collections/`.

**Tech Stack:** Rails 8, PostgreSQL, RSpec, FactoryBot, Shoulda Matchers, Tailwind CSS

---

### Task 1: Add slug to PodcastCategory

**Files:**
- Create: `db/migrate/XXXXXX_add_slug_to_podcast_categories.rb`
- Modify: `app/models/podcast_category.rb`
- Modify: `spec/models/podcast_category_spec.rb`
- Modify: `spec/factories/podcast_categories.rb`
- Modify: `db/seeds/podcast_episodes.yml`
- Modify: `db/seeds.rb`

**Step 1: Write the failing tests**

Add to `spec/models/podcast_category_spec.rb` inside the validations block:

```ruby
it { should validate_presence_of(:slug) }
it { should validate_uniqueness_of(:slug) }
```

Add a new describe block:

```ruby
describe 'slug generation' do
  it 'generates slug from name before validation' do
    category = build(:podcast_category, name: 'Software Practices', slug: nil)
    category.valid?
    expect(category.slug).to eq('software-practices')
  end

  it 'does not overwrite an existing slug' do
    category = build(:podcast_category, name: 'Software Practices', slug: 'custom-slug')
    category.valid?
    expect(category.slug).to eq('custom-slug')
  end
end

describe '.find_by_slug!' do
  it 'finds a category by slug' do
    category = create(:podcast_category, slug: 'software-practices')
    expect(PodcastCategory.find_by_slug!('software-practices')).to eq(category)
  end

  it 'raises RecordNotFound for unknown slug' do
    expect { PodcastCategory.find_by_slug!('nonexistent') }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
```

Update the factory in `spec/factories/podcast_categories.rb`:

```ruby
FactoryBot.define do
  factory :podcast_category do
    sequence(:name) { |n| "Podcast Category #{n}" }
    sequence(:slug) { |n| "podcast-category-#{n}" }
    position { 0 }
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb`
Expected: FAIL

**Step 3: Generate migration and update model**

Run:
```bash
bin/rails generate migration AddSlugToPodcastCategories slug:string
```

Edit the generated migration:

```ruby
class AddSlugToPodcastCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :podcast_categories, :slug, :string, null: false, default: ''
    add_index :podcast_categories, :slug, unique: true
  end
end
```

Update `app/models/podcast_category.rb`:

```ruby
class PodcastCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  has_many :podcast_episode_categories, dependent: :destroy
  has_many :podcast_episodes, through: :podcast_episode_categories

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :ordered, -> { order(:position) }

  def self.find_by_slug!(slug)
    find_by!(slug: slug)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name&.parameterize
  end
end
```

Add slugs to `db/seeds/podcast_episodes.yml` categories section:

```yaml
categories:
  - name: Software Practices
    slug: software-practices
    position: 1
  - name: Teams & Collaboration
    slug: teams-and-collaboration
    position: 2
  - name: Career & Learning
    slug: career-and-learning
    position: 3
  - name: Tech Meets Business
    slug: tech-meets-business
    position: 4
  - name: Technology Deep Dives
    slug: technology-deep-dives
    position: 5
```

Update the categories seeding in `db/seeds.rb` to include slug:

```ruby
categories_data.each do |cat_data|
  cat = PodcastCategory.find_or_create_by!(name: cat_data['name']) do |c|
    c.position = cat_data['position']
    c.slug = cat_data['slug']
  end
  created_categories += 1 if cat.previously_new_record?
end
```

Run: `bin/rails db:migrate`

**Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb`
Expected: PASS

**Step 5: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 6: Commit**

```bash
git add db/migrate/*_add_slug_to_podcast_categories.rb app/models/podcast_category.rb spec/models/podcast_category_spec.rb spec/factories/podcast_categories.rb db/seeds/podcast_episodes.yml db/seeds.rb db/schema.rb
git commit -m "feat: add slug to PodcastCategory with auto-generation"
```

---

### Task 2: Update routes and controller for collections

**Files:**
- Modify: `config/routes.rb`
- Modify: `app/controllers/podcast_episodes_controller.rb`
- Modify: `spec/requests/podcast_episodes_spec.rb`

**Step 1: Write the failing tests**

Replace the content of `spec/requests/podcast_episodes_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "PodcastEpisodes", type: :request do
  describe "GET /podcast" do
    it "returns success" do
      get podcast_path
      expect(response).to have_http_status(:success)
    end

    it "displays category cards" do
      category = create(:podcast_category, name: "Software Practices")
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category

      get podcast_path

      expect(response.body).to include("Software Practices")
    end

    it "displays episode count per category" do
      category = create(:podcast_category, name: "Software Practices")
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category

      get podcast_path

      expect(response.body).to include("2")
    end

    it "displays a See all card" do
      get podcast_path
      expect(response.body).to include("See all")
    end
  end

  describe "GET /podcast/collections/all" do
    it "returns success" do
      get podcast_collection_path("all")
      expect(response).to have_http_status(:success)
    end

    it "displays all episodes newest first" do
      old = create(:podcast_episode, title: "Old Episode", published_at: 1.week.ago)
      new_ep = create(:podcast_episode, title: "New Episode", published_at: 1.day.ago)

      get podcast_collection_path("all")

      expect(response.body.index("New Episode")).to be < response.body.index("Old Episode")
    end

    it "displays category badges on episodes" do
      episode = create(:podcast_episode, published_at: 1.day.ago)
      category = create(:podcast_category, name: "Software Practices")
      episode.podcast_categories << category

      get podcast_collection_path("all")

      expect(response.body).to include("Software Practices")
    end
  end

  describe "GET /podcast/collections/:slug" do
    it "returns success" do
      category = create(:podcast_category, slug: "software-practices")

      get podcast_collection_path(category.slug)
      expect(response).to have_http_status(:success)
    end

    it "displays only episodes in that category" do
      cat1 = create(:podcast_category, slug: "software-practices")
      cat2 = create(:podcast_category, slug: "career")

      ep1 = create(:podcast_episode, title: "In Category", published_at: 1.day.ago)
      ep1.podcast_categories << cat1
      ep2 = create(:podcast_episode, title: "Other Category", published_at: 1.day.ago)
      ep2.podcast_categories << cat2

      get podcast_collection_path(cat1.slug)

      expect(response.body).to include("In Category")
      expect(response.body).not_to include("Other Category")
    end

    it "returns 404 for unknown slug" do
      expect {
        get podcast_collection_path("nonexistent")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "displays the category name as heading" do
      category = create(:podcast_category, name: "Software Practices", slug: "software-practices")

      get podcast_collection_path(category.slug)

      expect(response.body).to include("Software Practices")
    end
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: FAIL — routes don't exist yet

**Step 3: Update routes**

In `config/routes.rb`, replace the podcast line:

```ruby
get "podcast", to: "podcast_episodes#index", as: :podcast
```

with:

```ruby
get "podcast", to: "podcast_episodes#index", as: :podcast
get "podcast/collections/:slug", to: "podcast_episodes#show", as: :podcast_collection
```

**Step 4: Update controller**

Replace `app/controllers/podcast_episodes_controller.rb`:

```ruby
class PodcastEpisodesController < ApplicationController
  def index
    @categories = PodcastCategory.ordered
    @total_episode_count = PodcastEpisode.published.count
  end

  def show
    if params[:slug] == "all"
      @title = "All Episodes"
      @episodes = PodcastEpisode.published.newest_first.includes(:podcast_categories)
    else
      @category = PodcastCategory.find_by_slug!(params[:slug])
      @title = @category.name
      @episodes = @category.podcast_episodes.published.newest_first.includes(:podcast_categories)
    end
  end
end
```

**Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: Some may still fail — views not created yet. That's OK, we handle views in Task 3.

**Step 6: Commit**

```bash
git add config/routes.rb app/controllers/podcast_episodes_controller.rb spec/requests/podcast_episodes_spec.rb
git commit -m "feat: add collections routes and controller actions"
```

---

### Task 3: Create collections and episode list views

**Files:**
- Modify: `app/views/podcast_episodes/index.html.erb` — replace with collections grid
- Create: `app/views/podcast_episodes/show.html.erb` — episode list view
- Keep: `app/views/podcast_episodes/_episode.html.erb` — unchanged

**Step 1: Replace `index.html.erb` with collections grid**

```erb
<div class="py-16">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-3xl font-bold mb-2">Podcast</h1>
    <p class="text-muted mb-12">Conversations about software, learning, and building things.</p>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <% @categories.each do |category| %>
        <%= link_to podcast_collection_path(category.slug), class: "bg-surface rounded-lg p-6 border border-muted/20 hover:border-primary/50 transition group" do %>
          <h3 class="text-lg font-semibold group-hover:text-primary transition"><%= category.name %></h3>
          <p class="text-sm text-muted mt-2"><%= category.podcast_episodes.published.count %> episodes</p>
        <% end %>
      <% end %>

      <%= link_to podcast_collection_path("all"), class: "bg-surface rounded-lg p-6 border border-muted/20 hover:border-primary/50 transition group" do %>
        <h3 class="text-lg font-semibold group-hover:text-primary transition">See all</h3>
        <p class="text-sm text-muted mt-2"><%= @total_episode_count %> episodes</p>
      <% end %>
    </div>
  </div>
</div>
```

**Step 2: Create `show.html.erb` for episode list**

```erb
<div class="py-16">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <%= link_to "<- Back to collections", podcast_path, class: "text-sm text-muted hover:text-text transition" %>

    <h1 class="text-3xl font-bold mb-2 mt-6"><%= @title %></h1>
    <p class="text-muted mb-12"><%= @episodes.size %> episodes</p>

    <% if @episodes.any? %>
      <div class="space-y-6">
        <% @episodes.each do |episode| %>
          <%= render "podcast_episodes/episode", episode: episode %>
        <% end %>
      </div>
    <% else %>
      <p class="text-muted">No episodes in this collection yet.</p>
    <% end %>
  </div>
</div>
```

**Step 3: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: PASS

**Step 4: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 5: Commit**

```bash
git add app/views/podcast_episodes/index.html.erb app/views/podcast_episodes/show.html.erb
git commit -m "feat: add collections grid and filtered episode list views"
```

---

### Task 4: Update homepage reference

**Files:**
- Modify: `app/views/pages/home.html.erb`

The homepage has a link `"All episodes ->"` pointing to `podcast_path`. This should now point to `podcast_collection_path("all")` since `/podcast` is now the collections page. Or it could stay as-is if you want it to link to the collections page.

**Step 1: Update link**

In `app/views/pages/home.html.erb`, change line 34:

```erb
<%= link_to "All episodes ->", podcast_path, class: "text-primary hover:text-primary/80 transition" %>
```

to:

```erb
<%= link_to "All episodes ->", podcast_collection_path("all"), class: "text-primary hover:text-primary/80 transition" %>
```

**Step 2: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 3: Commit**

```bash
git add app/views/pages/home.html.erb
git commit -m "fix: update homepage podcast link to all episodes collection"
```

---

### Task 5: Final verification and deployment

**Step 1: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 2: Run seeds on fresh database**

Run: `bin/rails db:reset`
Expected: All seeds run, categories have slugs

**Step 3: Manual smoke test**

Run: `bin/rails server`
- Visit `/podcast` — collections grid with 5 category cards + See all
- Click a category — filtered episode list with back link
- Click "See all" — all episodes
- Click back link — returns to collections grid
- Visit homepage — "All episodes" link goes to all episodes collection

**Step 4: Deploy to Heroku**

```bash
git push heroku main
heroku run rails db:seed -a p-learning-blog
```
