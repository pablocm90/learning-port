# Podcast Categories & Seed Data Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add topic-based categorization (many-to-many) to podcast episodes and seed all 27 episodes from the RSS feed.

**Architecture:** Two new tables (`podcast_categories`, `podcast_episode_categories` join table) with a `has_many :through` association in both directions. Seed data in YAML. Category badges on episode cards.

**Tech Stack:** Rails 8, PostgreSQL, RSpec, FactoryBot, Shoulda Matchers, Tailwind CSS

---

### Task 1: PodcastCategory model and migration

**Files:**
- Create: `db/migrate/XXXXXX_create_podcast_categories.rb`
- Create: `app/models/podcast_category.rb`
- Test: `spec/models/podcast_category_spec.rb`
- Create: `spec/factories/podcast_categories.rb`

**Step 1: Write the failing test**

Create `spec/models/podcast_category_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe PodcastCategory, type: :model do
  subject { build(:podcast_category) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:podcast_category, position: 2)
      cat1 = create(:podcast_category, position: 1)

      expect(PodcastCategory.ordered).to eq([cat1, cat2])
    end
  end
end
```

Create `spec/factories/podcast_categories.rb`:

```ruby
FactoryBot.define do
  factory :podcast_category do
    sequence(:name) { |n| "Podcast Category #{n}" }
    position { 0 }
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb`
Expected: FAIL — `uninitialized constant PodcastCategory`

**Step 3: Generate migration and create model**

Run:
```bash
bin/rails generate migration CreatePodcastCategories name:string position:integer
```

Edit the generated migration to add constraints:

```ruby
class CreatePodcastCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :podcast_categories do |t|
      t.string :name, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :podcast_categories, :name, unique: true
  end
end
```

Create `app/models/podcast_category.rb`:

```ruby
class PodcastCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
end
```

Run: `bin/rails db:migrate`

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb`
Expected: PASS (3 examples, 0 failures)

**Step 5: Commit**

```bash
git add db/migrate/*_create_podcast_categories.rb app/models/podcast_category.rb spec/models/podcast_category_spec.rb spec/factories/podcast_categories.rb db/schema.rb
git commit -m "feat: add PodcastCategory model with validations and ordered scope"
```

---

### Task 2: Join table and many-to-many associations

**Files:**
- Create: `db/migrate/XXXXXX_create_podcast_episode_categories.rb`
- Create: `app/models/podcast_episode_category.rb`
- Modify: `app/models/podcast_category.rb`
- Modify: `app/models/podcast_episode.rb`
- Modify: `spec/models/podcast_category_spec.rb`
- Modify: `spec/models/podcast_episode_spec.rb`

**Step 1: Write the failing tests**

Add to `spec/models/podcast_category_spec.rb` inside the top-level describe:

```ruby
describe 'associations' do
  it { should have_many(:podcast_episode_categories).dependent(:destroy) }
  it { should have_many(:podcast_episodes).through(:podcast_episode_categories) }
end
```

Add to `spec/models/podcast_episode_spec.rb` inside the top-level describe:

```ruby
describe 'associations' do
  it { should have_many(:podcast_episode_categories).dependent(:destroy) }
  it { should have_many(:podcast_categories).through(:podcast_episode_categories) }
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb spec/models/podcast_episode_spec.rb`
Expected: FAIL — association matchers fail

**Step 3: Generate migration and create join model**

Run:
```bash
bin/rails generate migration CreatePodcastEpisodeCategories podcast_episode:references podcast_category:references
```

Edit the generated migration:

```ruby
class CreatePodcastEpisodeCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :podcast_episode_categories do |t|
      t.references :podcast_episode, null: false, foreign_key: true
      t.references :podcast_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :podcast_episode_categories, [:podcast_episode_id, :podcast_category_id],
              unique: true, name: 'idx_episode_categories_unique'
  end
end
```

Create `app/models/podcast_episode_category.rb`:

```ruby
class PodcastEpisodeCategory < ApplicationRecord
  belongs_to :podcast_episode
  belongs_to :podcast_category
end
```

Add to `app/models/podcast_category.rb` (after the `validates` line):

```ruby
has_many :podcast_episode_categories, dependent: :destroy
has_many :podcast_episodes, through: :podcast_episode_categories
```

Add to `app/models/podcast_episode.rb` (after the `validates :episode_number` line):

```ruby
has_many :podcast_episode_categories, dependent: :destroy
has_many :podcast_categories, through: :podcast_episode_categories
```

Run: `bin/rails db:migrate`

**Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/podcast_category_spec.rb spec/models/podcast_episode_spec.rb`
Expected: PASS

**Step 5: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 6: Commit**

```bash
git add db/migrate/*_create_podcast_episode_categories.rb app/models/podcast_episode_category.rb app/models/podcast_category.rb app/models/podcast_episode.rb spec/models/podcast_category_spec.rb spec/models/podcast_episode_spec.rb db/schema.rb
git commit -m "feat: add many-to-many between PodcastEpisode and PodcastCategory"
```

---

### Task 3: Seed data — podcast episodes and categories

**Files:**
- Modify: `db/seeds/podcast_episodes.yml` — populate with all 27 episodes and category assignments
- Modify: `db/seeds.rb` — update podcast seeding to handle categories

**Step 1: Populate `db/seeds/podcast_episodes.yml`**

Replace the entire file with the full episode data. Each episode includes a `categories` list. Episode descriptions come from the RSS feed summaries.

```yaml
# Podcast categories
categories:
  - name: Software Practices
    position: 1
  - name: Teams & Collaboration
    position: 2
  - name: Career & Learning
    position: 3
  - name: Tech Meets Business
    position: 4
  - name: Technology Deep Dives
    position: 5

# Podcast episodes
episodes:
  - title: "On Power and Responsibility"
    episode_number: 1
    published_at: 2024-05-08
    description: "Software engineer power and ethical responsibilities in technology development."
    categories:
      - Career & Learning

  - title: "On Continuous Learning"
    episode_number: 2
    published_at: 2024-03-28
    description: "Continuous learning in tech industry contexts and professional development."
    categories:
      - Career & Learning

  - title: "On Solo-preneurship"
    episode_number: 3
    published_at: 2024-06-17
    description: "Solo-preneurship journey experiences with projects like Zero Config Rails and Proggy.io."
    categories:
      - Tech Meets Business

  - title: "On Being a Generalist"
    episode_number: 4
    published_at: 2024-09-27
    description: "Generalist identity, thriving amid specialization pressures, and career journey lessons."
    categories:
      - Career & Learning

  - title: "On Sales and Tech"
    episode_number: 5
    published_at: 2024-10-12
    description: "Sales-tech relationship dynamics and sales process understanding for technologists."
    categories:
      - Tech Meets Business

  - title: "On Agile"
    episode_number: 6
    published_at: 2024-11-08
    description: "Agile practices, experiences, and insights; DORA metrics and Modern Agile frameworks discussed."
    categories:
      - Software Practices
      - Teams & Collaboration

  - title: "On What Makes a Good Team"
    episode_number: 7
    published_at: 2024-11-18
    description: "Team composition, leadership roles, and team dynamics using the Belbin team roles framework."
    categories:
      - Teams & Collaboration

  - title: "On eXtreme Programming"
    episode_number: 8
    published_at: 2025-01-05
    description: "eXtreme Programming practices, principles, and experience-based insights."
    categories:
      - Software Practices

  - title: "On Customer Support/Experience and Tech"
    episode_number: 9
    published_at: 2025-01-13
    description: "Customer support and success roles and their relationship with technology departments."
    categories:
      - Tech Meets Business

  - title: "On Tests First"
    episode_number: 10
    published_at: 2025-01-16
    description: "Test-first development advantages, testable code correlation with quality, and common counterarguments."
    categories:
      - Software Practices

  - title: "On Tests and RSpec"
    episode_number: 11
    published_at: 2025-02-14
    description: "Testing best practices, RSpec guidance, common pitfalls, and real-world developer insights."
    categories:
      - Software Practices

  - title: "On Team Efficiency"
    episode_number: 12
    published_at: 2025-02-23
    description: "Team efficiency drivers, outcome-focused practices, and enhancement strategies."
    categories:
      - Teams & Collaboration

  - title: "On Building a Community"
    episode_number: 13
    published_at: 2025-03-04
    description: "Community building strategies, passion, and effort across different community types."
    categories:
      - Career & Learning

  - title: "On Legacy Code"
    episode_number: 14
    published_at: 2025-06-06
    description: "Legacy code definitions, working strategies, and quality assessment."
    categories:
      - Software Practices

  - title: "On Software Teaming"
    episode_number: 15
    published_at: 2025-06-16
    description: "Collaborative team problem-solving, organization for inclusive participation, and team dynamics exploration."
    categories:
      - Teams & Collaboration

  - title: "On DDD (Domain-Driven Design)"
    episode_number: 16
    published_at: 2025-07-04
    description: "DDD utility, applicability contexts, problem-solving benefits, and implementation recommendations."
    categories:
      - Software Practices
      - Technology Deep Dives

  - title: "On Marketing and Tech"
    episode_number: 17
    published_at: 2025-07-17
    description: "Marketing-tech relationships and inter-departmental collaboration insights."
    categories:
      - Tech Meets Business

  - title: "On Starting a New Role"
    episode_number: 18
    published_at: 2025-08-04
    description: "Considerations for new roles, colleague integration strategies, and initial task selection."
    categories:
      - Career & Learning
      - Teams & Collaboration

  - title: "On Metrics"
    episode_number: 19
    published_at: 2025-08-14
    description: "Worthwhile metrics, metric dangers, and contexts where metrics prove useful."
    categories:
      - Tech Meets Business
      - Teams & Collaboration

  - title: "On LLMs"
    episode_number: 20
    published_at: 2025-08-19
    description: "LLM usage, implementation considerations, and philosophical questions about artificial intelligence and ethics."
    categories:
      - Technology Deep Dives

  - title: "On PWAs"
    episode_number: 21
    published_at: 2025-09-28
    description: "Progressive Web Applications viability and their specific use cases."
    categories:
      - Technology Deep Dives

  - title: "On Team Practices"
    episode_number: 22
    published_at: 2025-10-06
    description: "Team practices for excellent software writing and continuous integration."
    categories:
      - Software Practices
      - Teams & Collaboration

  - title: "On Bootcamps"
    episode_number: 23
    published_at: 2025-10-23
    description: "Bootcamp experiences, industry integration advice for graduates, and bootcamps' current and future relevance."
    categories:
      - Career & Learning

  - title: "On Misunderstood Concepts in Tech"
    episode_number: 24
    published_at: 2025-10-28
    description: "Tech misunderstandings, comparison of car vs. tech industry maturity, and reflections on developer roles."
    categories:
      - Technology Deep Dives

  - title: "On Taste"
    episode_number: 25
    published_at: 2025-11-18
    description: "Exploring taste in programming — whether it's universal and how mistakes shape coding aesthetics."
    categories:
      - Software Practices
      - Career & Learning

  - title: "On OOP"
    episode_number: 26
    published_at: 2025-12-16
    description: "Object-oriented programming exploration covering origins, naming conventions, design patterns, and modeling reality with objects."
    categories:
      - Software Practices
      - Technology Deep Dives

  - title: "On Ruby (and Rails?)"
    episode_number: 27
    published_at: 2026-01-07
    description: "Ruby's elegance, community standards, type systems, and Rails' role in web development."
    categories:
      - Technology Deep Dives
```

**Step 2: Update `db/seeds.rb` podcast section**

Replace the `# Podcast Episodes from YAML` section (lines 64-102) with:

```ruby
# =============================================================================
# Podcast Episodes and Categories from YAML
# =============================================================================
puts "\nSeeding podcast episodes and categories from YAML..."

podcast_data_path = Rails.root.join('db/seeds/podcast_episodes.yml')
if File.exist?(podcast_data_path)
  podcast_data = YAML.safe_load_file(podcast_data_path, permitted_classes: [Date, Time, DateTime]) || {}

  # Seed podcast categories
  categories_data = podcast_data['categories'] || []
  created_categories = 0

  categories_data.each do |cat_data|
    cat = PodcastCategory.find_or_create_by!(name: cat_data['name']) do |c|
      c.position = cat_data['position']
    end
    created_categories += 1 if cat.previously_new_record?
  end
  puts "  Podcast categories: #{created_categories} created (#{PodcastCategory.count} total)"

  # Seed podcast episodes
  episodes_data = podcast_data['episodes'] || []
  created_episodes = 0
  updated_episodes = 0

  episodes_data.each do |episode_data|
    episode = PodcastEpisode.find_or_initialize_by(episode_number: episode_data['episode_number'])
    was_new = episode.new_record?

    episode.assign_attributes(
      title: episode_data['title'],
      description: episode_data['description'],
      published_at: episode_data['published_at'],
      embed_code: episode_data['embed_code'],
      external_links: episode_data['external_links'] || {}
    )

    if episode.save
      # Assign categories
      category_names = episode_data['categories'] || []
      categories = PodcastCategory.where(name: category_names)
      episode.podcast_categories = categories

      if was_new
        created_episodes += 1
        puts "  -> Created: Episode #{episode.episode_number} - #{episode.title}"
      else
        updated_episodes += 1
        puts "  -> Updated: Episode #{episode.episode_number} - #{episode.title}"
      end
    else
      puts "  -> Failed: Episode #{episode_data['episode_number']} - #{episode.errors.full_messages.join(', ')}"
    end
  end

  puts "  Podcast episodes: #{created_episodes} created, #{updated_episodes} updated"
else
  puts "  -> No podcast_episodes.yml found, skipping..."
end
```

**Step 3: Run seeds to verify**

Run: `bin/rails db:seed`
Expected: Output showing 5 categories created and 27 episodes created with category assignments

**Step 4: Verify in console**

Run: `bin/rails runner "puts PodcastEpisode.count; puts PodcastCategory.count; puts PodcastEpisodeCategory.count"`
Expected: 27, 5, and a count matching total assignments (37 based on design)

**Step 5: Commit**

```bash
git add db/seeds/podcast_episodes.yml db/seeds.rb
git commit -m "feat: seed 27 podcast episodes with 5 topic categories"
```

---

### Task 4: Display category badges on episode cards

**Files:**
- Modify: `app/views/podcast_episodes/_episode.html.erb`
- Modify: `app/controllers/podcast_episodes_controller.rb`
- Modify: `spec/requests/podcast_episodes_spec.rb`

**Step 1: Write the failing test**

Add to `spec/requests/podcast_episodes_spec.rb`:

```ruby
it "displays category badges on episodes" do
  episode = create(:podcast_episode, published_at: 1.day.ago)
  category = create(:podcast_category, name: "Software Practices")
  episode.podcast_categories << category

  get podcast_path

  expect(response.body).to include("Software Practices")
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: FAIL — "Software Practices" not found in response body

**Step 3: Update controller to eager-load categories**

In `app/controllers/podcast_episodes_controller.rb`, change:

```ruby
@episodes = PodcastEpisode.published.newest_first
```

to:

```ruby
@episodes = PodcastEpisode.published.newest_first.includes(:podcast_categories)
```

**Step 4: Add category badges to the episode partial**

In `app/views/podcast_episodes/_episode.html.erb`, add category badges after the date line (after line 8, before line 9):

```erb
<% if episode.podcast_categories.any? %>
  <div class="flex flex-wrap gap-2 mt-2">
    <% episode.podcast_categories.each do |category| %>
      <span class="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary"><%= category.name %></span>
    <% end %>
  </div>
<% end %>
```

**Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: PASS

**Step 6: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 7: Commit**

```bash
git add app/views/podcast_episodes/_episode.html.erb app/controllers/podcast_episodes_controller.rb spec/requests/podcast_episodes_spec.rb
git commit -m "feat: display podcast category badges on episode cards"
```

---

### Task 5: Add category checkboxes to admin podcast episode form

**Files:**
- Modify: `app/views/admin/podcast_episodes/_form.html.erb`
- Modify: `app/controllers/admin/podcast_episodes_controller.rb`
- Modify: `spec/requests/admin/podcast_episodes_spec.rb`

**Step 1: Write the failing test**

Add to `spec/requests/admin/podcast_episodes_spec.rb` inside the `POST` describe block:

```ruby
it "creates a podcast episode with categories" do
  category = create(:podcast_category, name: "Software Practices")

  post admin_podcast_episodes_path, params: {
    podcast_episode: {
      title: "Episode with Categories",
      episode_number: 99,
      description: "Testing categories",
      published_at: Date.today,
      podcast_category_ids: [category.id]
    }
  }

  episode = PodcastEpisode.last
  expect(episode.podcast_categories).to include(category)
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/podcast_episodes_spec.rb`
Expected: FAIL — categories not assigned (unpermitted parameter)

**Step 3: Update strong params in admin controller**

In `app/controllers/admin/podcast_episodes_controller.rb`, change the `podcast_episode_params` method:

```ruby
def podcast_episode_params
  params.require(:podcast_episode).permit(
    :title, :episode_number, :description, :published_at, :embed_code,
    podcast_category_ids: []
  )
end
```

**Step 4: Add category checkboxes to the form**

In `app/views/admin/podcast_episodes/_form.html.erb`, add before the submit button div (before line 40):

```erb
<div>
  <span class="block text-sm font-medium text-muted mb-2">Categories</span>
  <div class="flex flex-wrap gap-4">
    <% PodcastCategory.ordered.each do |category| %>
      <label class="flex items-center gap-2 text-sm text-text cursor-pointer">
        <%= check_box_tag "podcast_episode[podcast_category_ids][]", category.id,
            podcast_episode.podcast_category_ids.include?(category.id),
            class: "rounded border-muted/30 bg-background text-primary focus:ring-primary" %>
        <%= category.name %>
      </label>
    <% end %>
  </div>
</div>
```

**Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/requests/admin/podcast_episodes_spec.rb`
Expected: PASS

**Step 6: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 7: Commit**

```bash
git add app/views/admin/podcast_episodes/_form.html.erb app/controllers/admin/podcast_episodes_controller.rb spec/requests/admin/podcast_episodes_spec.rb
git commit -m "feat: add category selection to admin podcast episode form"
```

---

### Task 6: Final verification

**Step 1: Run full test suite**

Run: `bundle exec rspec`
Expected: All green

**Step 2: Run seeds on fresh database**

Run: `bin/rails db:reset`
Expected: Database recreated, all seeds run successfully, 27 episodes and 5 categories created

**Step 3: Manual smoke test**

Run: `bin/rails server`
- Visit `/podcast` — verify all 27 episodes display with category badges
- Visit `/admin` — verify podcast episode forms show category checkboxes
- Create/edit an episode in admin — verify categories save correctly

**Step 4: Commit any remaining changes**

If any fixes were needed, commit them.
