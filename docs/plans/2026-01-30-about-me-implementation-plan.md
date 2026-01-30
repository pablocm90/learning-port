# About Me Site Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a personal portfolio site with learning portfolio, podcast page, and blog integration using Rails 8, Hotwire, and Tailwind CSS.

**Architecture:** Server-rendered Rails 8 app with Turbo for smooth navigation, Stimulus for interactive components, SQLite database, and Devise for admin auth. YAML seeding for bulk content management.

**Tech Stack:** Ruby 3.3, Rails 8, Hotwire (Turbo + Stimulus), Tailwind CSS 4, SQLite, Devise, RSpec

---

## Phase 1: Project Setup

### Task 1: Create Fresh Rails 8 App

**Files:**
- Create: New Rails 8 application in current directory

**Step 1: Remove old code and create new Rails app**

First, preserve the design docs, then create fresh Rails 8 app:

```bash
# Move plans out temporarily
mv docs /tmp/about-me-docs

# Remove all old files
rm -rf ./* ./.*

# Create new Rails 8 app with SQLite, Tailwind, and skip test (we'll use RSpec)
rails new . --database=sqlite3 --css=tailwind --skip-test --skip-jbuilder

# Restore docs
mv /tmp/about-me-docs docs
```

**Step 2: Verify app runs**

Run: `bin/rails server`
Expected: Server starts on localhost:3000, default Rails page shows

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: create fresh Rails 8 app with Tailwind"
```

---

### Task 2: Add RSpec and Testing Setup

**Files:**
- Modify: `Gemfile`
- Create: `spec/spec_helper.rb`
- Create: `spec/rails_helper.rb`

**Step 1: Add testing gems to Gemfile**

Add to Gemfile in the test group:

```ruby
group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end
```

**Step 2: Install and initialize RSpec**

```bash
bundle install
bin/rails generate rspec:install
```

**Step 3: Configure shoulda-matchers**

Add to `spec/rails_helper.rb` at the end:

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

**Step 4: Configure Factory Bot**

Add to `spec/rails_helper.rb` inside the `RSpec.configure` block:

```ruby
config.include FactoryBot::Syntax::Methods
```

**Step 5: Run RSpec to verify setup**

Run: `bundle exec rspec`
Expected: "0 examples, 0 failures"

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: add RSpec testing setup with FactoryBot and Shoulda"
```

---

### Task 3: Configure Tailwind Theme

**Files:**
- Modify: `app/assets/stylesheets/application.tailwind.css`
- Modify: `config/tailwind.config.js`

**Step 1: Update Tailwind config with custom theme**

Replace `config/tailwind.config.js`:

```javascript
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        background: '#0f172a',
        surface: '#1e293b',
        primary: '#3b82f6',
        secondary: '#10b981',
        text: '#f1f5f9',
        muted: '#94a3b8',
      },
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

**Step 2: Add Tailwind plugins**

```bash
yarn add @tailwindcss/forms @tailwindcss/typography
```

**Step 3: Update base styles**

Replace `app/assets/stylesheets/application.tailwind.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-background text-text antialiased;
  }
}
```

**Step 4: Verify Tailwind compiles**

Run: `bin/rails tailwindcss:build`
Expected: No errors, CSS file generated

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: configure Tailwind with dark theme and custom colors"
```

---

### Task 4: Add Google Fonts

**Files:**
- Modify: `app/views/layouts/application.html.erb`

**Step 1: Add font links to layout head**

In `app/views/layouts/application.html.erb`, add before `<%= stylesheet_link_tag %>`:

```erb
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

**Step 2: Verify fonts load**

Run: `bin/rails server`
Expected: Page loads with Inter font visible

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: add Inter and JetBrains Mono fonts"
```

---

## Phase 2: Authentication

### Task 5: Add Devise for Admin Authentication

**Files:**
- Modify: `Gemfile`
- Create: `app/models/writer.rb`
- Create: `db/migrate/*_devise_create_writers.rb`
- Create: `spec/models/writer_spec.rb`
- Create: `spec/factories/writers.rb`

**Step 1: Add Devise to Gemfile**

```ruby
gem "devise"
```

**Step 2: Install Devise**

```bash
bundle install
bin/rails generate devise:install
```

**Step 3: Configure Devise for Turbo**

In `config/initializers/devise.rb`, set:

```ruby
config.navigational_formats = ['*/*', :html, :turbo_stream]
```

**Step 4: Write failing test for Writer model**

Create `spec/models/writer_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Writer, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
  end

  describe 'attributes' do
    it 'has a bio' do
      writer = Writer.new(bio: 'Hello world')
      expect(writer.bio).to eq('Hello world')
    end
  end
end
```

**Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/writer_spec.rb`
Expected: FAIL - "uninitialized constant Writer"

**Step 6: Generate Writer model with Devise**

```bash
bin/rails generate devise Writer name:string bio:text
```

**Step 7: Add name validation to Writer model**

Update `app/models/writer.rb`:

```ruby
class Writer < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  validates :name, presence: true
end
```

**Step 8: Run migration**

```bash
bin/rails db:migrate
```

**Step 9: Create factory**

Create `spec/factories/writers.rb`:

```ruby
FactoryBot.define do
  factory :writer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    bio { Faker::Lorem.paragraph }
  end
end
```

**Step 10: Run tests**

Run: `bundle exec rspec spec/models/writer_spec.rb`
Expected: PASS - all tests green

**Step 11: Commit**

```bash
git add -A
git commit -m "feat: add Writer model with Devise authentication"
```

---

### Task 6: Disable Public Registration

**Files:**
- Modify: `app/models/writer.rb`
- Modify: `config/routes.rb`
- Create: `db/seeds.rb` (admin seed)

**Step 1: Remove registerable from Devise**

In `app/models/writer.rb`, remove `:registerable` from devise modules (it shouldn't be there by default, but verify).

**Step 2: Configure routes to skip registration**

In `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  root "pages#home"
end
```

**Step 3: Create admin seed**

Update `db/seeds.rb`:

```ruby
# Create admin writer if none exists
Writer.find_or_create_by!(email: 'admin@example.com') do |writer|
  writer.name = 'Pablo'
  writer.password = 'changeme123'
  writer.bio = 'Software developer and lifelong learner.'
end

puts "Admin writer created: admin@example.com / changeme123"
```

**Step 4: Run seeds**

```bash
bin/rails db:seed
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: disable public registration, add admin seed"
```

---

## Phase 3: Core Models

### Task 7: Create LearningItem Model

**Files:**
- Create: `app/models/learning_item.rb`
- Create: `db/migrate/*_create_learning_items.rb`
- Create: `spec/models/learning_item_spec.rb`
- Create: `spec/factories/learning_items.rb`

**Step 1: Write failing test**

Create `spec/models/learning_item_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe LearningItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(learning: 0, practicing: 1, comfortable: 2, expert: 3) }
  end

  describe 'scopes' do
    it 'orders by position' do
      item2 = create(:learning_item, position: 2)
      item1 = create(:learning_item, position: 1)

      expect(LearningItem.ordered).to eq([item1, item2])
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/learning_item_spec.rb`
Expected: FAIL - "uninitialized constant LearningItem"

**Step 3: Generate migration**

```bash
bin/rails generate model LearningItem \
  name:string \
  icon:string \
  category:string \
  status:integer \
  description:text \
  started_at:date \
  resources:jsonb \
  notes:text \
  projects:jsonb \
  position:integer \
  source:string
```

**Step 4: Update migration with defaults**

Edit the migration file to add defaults:

```ruby
t.jsonb :resources, default: []
t.jsonb :projects, default: []
t.integer :position, default: 0
t.string :source, default: 'admin'
```

**Step 5: Run migration**

```bash
bin/rails db:migrate
```

**Step 6: Implement model**

Update `app/models/learning_item.rb`:

```ruby
class LearningItem < ApplicationRecord
  enum :status, { learning: 0, practicing: 1, comfortable: 2, expert: 3 }

  validates :name, presence: true
  validates :category, presence: true
  validates :status, presence: true

  scope :ordered, -> { order(:position) }
  scope :by_category, ->(category) { where(category: category) }
  scope :from_yaml, -> { where(source: 'yaml') }
  scope :from_admin, -> { where(source: 'admin') }
end
```

**Step 7: Create factory**

Create `spec/factories/learning_items.rb`:

```ruby
FactoryBot.define do
  factory :learning_item do
    name { Faker::ProgrammingLanguage.name }
    icon { '💻' }
    category { %w[Languages Frameworks DevOps Concepts].sample }
    status { :learning }
    description { Faker::Lorem.sentence }
    started_at { Faker::Date.backward(days: 365) }
    resources { [] }
    projects { [] }
    position { 0 }
    source { 'admin' }
  end
end
```

**Step 8: Run tests**

Run: `bundle exec rspec spec/models/learning_item_spec.rb`
Expected: PASS

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: add LearningItem model with status enum"
```

---

### Task 8: Create PodcastEpisode Model

**Files:**
- Create: `app/models/podcast_episode.rb`
- Create: `db/migrate/*_create_podcast_episodes.rb`
- Create: `spec/models/podcast_episode_spec.rb`
- Create: `spec/factories/podcast_episodes.rb`

**Step 1: Write failing test**

Create `spec/models/podcast_episode_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe PodcastEpisode, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:episode_number) }
    it { should validate_uniqueness_of(:episode_number) }
  end

  describe 'scopes' do
    it 'orders by newest first' do
      old = create(:podcast_episode, published_at: 1.week.ago)
      new_ep = create(:podcast_episode, published_at: 1.day.ago)

      expect(PodcastEpisode.newest_first).to eq([new_ep, old])
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/podcast_episode_spec.rb`
Expected: FAIL - "uninitialized constant PodcastEpisode"

**Step 3: Generate model**

```bash
bin/rails generate model PodcastEpisode \
  title:string \
  description:text \
  episode_number:integer \
  published_at:date \
  embed_code:text \
  external_links:jsonb
```

**Step 4: Update migration with defaults**

Edit the migration to add:

```ruby
t.jsonb :external_links, default: {}
```

Add index for uniqueness:

```ruby
add_index :podcast_episodes, :episode_number, unique: true
```

**Step 5: Run migration**

```bash
bin/rails db:migrate
```

**Step 6: Implement model**

Update `app/models/podcast_episode.rb`:

```ruby
class PodcastEpisode < ApplicationRecord
  validates :title, presence: true
  validates :episode_number, presence: true, uniqueness: true

  scope :newest_first, -> { order(published_at: :desc) }
  scope :published, -> { where('published_at <= ?', Date.current) }
end
```

**Step 7: Create factory**

Create `spec/factories/podcast_episodes.rb`:

```ruby
FactoryBot.define do
  factory :podcast_episode do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:episode_number)
    published_at { Faker::Date.backward(days: 30) }
    embed_code { '<iframe src="https://open.spotify.com/embed/episode/xxx"></iframe>' }
    external_links { { spotify: 'https://spotify.com', apple: 'https://apple.com' } }
  end
end
```

**Step 8: Run tests**

Run: `bundle exec rspec spec/models/podcast_episode_spec.rb`
Expected: PASS

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: add PodcastEpisode model"
```

---

## Phase 4: Layout and Navigation

### Task 9: Create Application Layout

**Files:**
- Modify: `app/views/layouts/application.html.erb`
- Create: `app/views/shared/_navbar.html.erb`
- Create: `app/views/shared/_footer.html.erb`
- Create: `app/helpers/application_helper.rb` (update)

**Step 1: Create navbar partial**

Create `app/views/shared/_navbar.html.erb`:

```erb
<nav class="bg-surface border-b border-muted/20">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between h-16">
      <div class="flex items-center">
        <%= link_to root_path, class: "text-xl font-semibold text-text hover:text-primary transition" do %>
          Pablo CM
        <% end %>
      </div>

      <div class="hidden md:flex items-center space-x-8">
        <%= link_to "Learning", learning_portfolio_path, class: nav_link_class(learning_portfolio_path) %>
        <%= link_to "Podcast", podcast_path, class: nav_link_class(podcast_path) %>
        <%= link_to "Blog", "https://blog.example.com", class: "text-muted hover:text-text transition", target: "_blank" %>

        <% if writer_signed_in? %>
          <%= link_to "Dashboard", admin_dashboard_path, class: nav_link_class(admin_dashboard_path) %>
          <%= button_to "Sign out", destroy_writer_session_path, method: :delete, class: "text-muted hover:text-text transition" %>
        <% end %>
      </div>

      <!-- Mobile menu button -->
      <div class="md:hidden flex items-center">
        <button type="button" data-controller="mobile-menu" data-action="click->mobile-menu#toggle" class="text-muted hover:text-text">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </div>
  </div>

  <!-- Mobile menu -->
  <div class="md:hidden hidden" data-mobile-menu-target="menu">
    <div class="px-2 pt-2 pb-3 space-y-1">
      <%= link_to "Learning", learning_portfolio_path, class: "block px-3 py-2 text-muted hover:text-text" %>
      <%= link_to "Podcast", podcast_path, class: "block px-3 py-2 text-muted hover:text-text" %>
      <%= link_to "Blog", "https://blog.example.com", class: "block px-3 py-2 text-muted hover:text-text", target: "_blank" %>
    </div>
  </div>
</nav>
```

**Step 2: Create footer partial**

Create `app/views/shared/_footer.html.erb`:

```erb
<footer class="bg-surface border-t border-muted/20 mt-auto">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex flex-col md:flex-row justify-between items-center">
      <div class="text-muted text-sm">
        &copy; <%= Date.current.year %> Pablo CM. All rights reserved.
      </div>

      <div class="flex items-center space-x-6 mt-4 md:mt-0">
        <%= link_to "mailto:contact@example.com", class: "text-muted hover:text-primary transition" do %>
          <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
        <% end %>

        <%= link_to "https://github.com/pablocm90", class: "text-muted hover:text-primary transition", target: "_blank" do %>
          <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
            <path fill-rule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clip-rule="evenodd" />
          </svg>
        <% end %>

        <%= link_to "https://linkedin.com/in/pablocm", class: "text-muted hover:text-primary transition", target: "_blank" do %>
          <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
          </svg>
        <% end %>
      </div>
    </div>
  </div>
</footer>
```

**Step 3: Add helper for nav links**

Update `app/helpers/application_helper.rb`:

```ruby
module ApplicationHelper
  def nav_link_class(path)
    base = "transition"
    if current_page?(path)
      "#{base} text-primary"
    else
      "#{base} text-muted hover:text-text"
    end
  end
end
```

**Step 4: Update application layout**

Replace `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html class="h-full">
  <head>
    <title>Pablo CM</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="description" content="Software developer and lifelong learner">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="h-full flex flex-col">
    <%= render "shared/navbar" %>

    <main class="flex-1">
      <% if notice.present? %>
        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 mt-4">
          <div class="bg-secondary/20 text-secondary px-4 py-3 rounded-lg">
            <%= notice %>
          </div>
        </div>
      <% end %>

      <% if alert.present? %>
        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 mt-4">
          <div class="bg-red-500/20 text-red-400 px-4 py-3 rounded-lg">
            <%= alert %>
          </div>
        </div>
      <% end %>

      <%= yield %>
    </main>

    <%= render "shared/footer" %>
  </body>
</html>
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add application layout with navbar and footer"
```

---

### Task 10: Create Mobile Menu Stimulus Controller

**Files:**
- Create: `app/javascript/controllers/mobile_menu_controller.js`

**Step 1: Create controller**

Create `app/javascript/controllers/mobile_menu_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}
```

**Step 2: Verify Stimulus is loaded**

Run: `bin/rails server`
Expected: Mobile menu toggles on click

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add mobile menu Stimulus controller"
```

---

## Phase 5: Public Pages

### Task 11: Create Pages Controller and Home Page

**Files:**
- Create: `app/controllers/pages_controller.rb`
- Create: `app/views/pages/home.html.erb`
- Modify: `config/routes.rb`
- Create: `spec/requests/pages_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/pages_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays the home page" do
      get root_path
      expect(response.body).to include("Pablo")
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/pages_spec.rb`
Expected: FAIL - route not defined

**Step 3: Create controller**

Create `app/controllers/pages_controller.rb`:

```ruby
class PagesController < ApplicationController
  def home
    @latest_episode = PodcastEpisode.published.newest_first.first
    @learning_highlights = LearningItem.where(status: :learning).ordered.limit(4)
  end
end
```

**Step 4: Add route**

Update `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  root "pages#home"

  get "learning", to: "learning_items#index", as: :learning_portfolio
  get "podcast", to: "podcast_episodes#index", as: :podcast
end
```

**Step 5: Create home view**

Create `app/views/pages/home.html.erb`:

```erb
<!-- Hero Section -->
<section class="py-20 md:py-32">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl md:text-6xl font-bold mb-6">
      Hi, I'm <span class="text-primary">Pablo</span>
    </h1>
    <p class="text-xl md:text-2xl text-muted max-w-2xl">
      Software developer and lifelong learner. I build things, share what I learn, and occasionally talk about it on my podcast.
    </p>
  </div>
</section>

<!-- Currently Learning Section -->
<section class="py-16 bg-surface">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-semibold">Currently Learning</h2>
      <%= link_to "See all →", learning_portfolio_path, class: "text-primary hover:text-primary/80 transition" %>
    </div>

    <% if @learning_highlights.any? %>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <% @learning_highlights.each do |item| %>
          <%= render "learning_items/card", learning_item: item %>
        <% end %>
      </div>
    <% else %>
      <p class="text-muted">No learning items yet.</p>
    <% end %>
  </div>
</section>

<!-- Latest Podcast Episode -->
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-semibold">Latest Episode</h2>
      <%= link_to "All episodes →", podcast_path, class: "text-primary hover:text-primary/80 transition" %>
    </div>

    <% if @latest_episode %>
      <%= render "podcast_episodes/featured", episode: @latest_episode %>
    <% else %>
      <p class="text-muted">No episodes yet.</p>
    <% end %>
  </div>
</section>

<!-- Latest Blog Post (RSS) -->
<section class="py-16 bg-surface">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-semibold">Latest from the Blog</h2>
      <%= link_to "Read more →", "https://blog.example.com", class: "text-primary hover:text-primary/80 transition", target: "_blank" %>
    </div>

    <%= turbo_frame_tag "latest_blog_post", src: latest_blog_post_path, loading: :lazy do %>
      <div class="animate-pulse bg-background rounded-lg h-32"></div>
    <% end %>
  </div>
</section>
```

**Step 6: Run tests**

Run: `bundle exec rspec spec/requests/pages_spec.rb`
Expected: PASS

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: add home page with hero and content sections"
```

---

### Task 12: Create Learning Item Card Partial

**Files:**
- Create: `app/views/learning_items/_card.html.erb`

**Step 1: Create card partial**

Create `app/views/learning_items/_card.html.erb`:

```erb
<div class="bg-background rounded-lg p-4 border border-muted/20 hover:border-primary/50 transition">
  <div class="flex items-start space-x-3">
    <span class="text-2xl"><%= learning_item.icon %></span>
    <div class="flex-1 min-w-0">
      <h3 class="font-medium text-text truncate"><%= learning_item.name %></h3>
      <p class="text-sm text-muted"><%= learning_item.category %></p>
      <span class="inline-block mt-2 px-2 py-1 text-xs rounded-full
        <%= case learning_item.status
            when 'learning' then 'bg-primary/20 text-primary'
            when 'practicing' then 'bg-yellow-500/20 text-yellow-400'
            when 'comfortable' then 'bg-secondary/20 text-secondary'
            when 'expert' then 'bg-purple-500/20 text-purple-400'
            end %>">
        <%= learning_item.status.humanize %>
      </span>
    </div>
  </div>
</div>
```

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: add learning item card partial"
```

---

### Task 13: Create Podcast Episode Partials

**Files:**
- Create: `app/views/podcast_episodes/_featured.html.erb`
- Create: `app/views/podcast_episodes/_episode.html.erb`

**Step 1: Create featured episode partial**

Create `app/views/podcast_episodes/_featured.html.erb`:

```erb
<div class="bg-surface rounded-lg p-6 border border-muted/20">
  <div class="flex flex-col lg:flex-row gap-6">
    <div class="flex-1">
      <span class="text-sm text-muted">Episode <%= episode.episode_number %></span>
      <h3 class="text-xl font-semibold mt-1 mb-3"><%= episode.title %></h3>
      <p class="text-muted line-clamp-3"><%= episode.description %></p>

      <% if episode.external_links.present? %>
        <div class="flex gap-4 mt-4">
          <% episode.external_links.each do |platform, url| %>
            <%= link_to platform.to_s.humanize, url, class: "text-sm text-primary hover:text-primary/80 transition", target: "_blank" %>
          <% end %>
        </div>
      <% end %>
    </div>

    <% if episode.embed_code.present? %>
      <div class="lg:w-80 flex-shrink-0">
        <%= raw episode.embed_code %>
      </div>
    <% end %>
  </div>
</div>
```

**Step 2: Create episode list partial**

Create `app/views/podcast_episodes/_episode.html.erb`:

```erb
<div class="bg-surface rounded-lg p-6 border border-muted/20">
  <div class="flex flex-col gap-4">
    <div>
      <div class="flex items-center gap-3 mb-2">
        <span class="text-sm text-muted">Episode <%= episode.episode_number %></span>
        <span class="text-sm text-muted">•</span>
        <span class="text-sm text-muted"><%= episode.published_at.strftime("%B %d, %Y") %></span>
      </div>
      <h3 class="text-lg font-semibold mb-2"><%= episode.title %></h3>
      <p class="text-muted text-sm"><%= episode.description %></p>
    </div>

    <% if episode.embed_code.present? %>
      <div class="mt-2">
        <%= raw episode.embed_code %>
      </div>
    <% end %>

    <% if episode.external_links.present? %>
      <div class="flex gap-4">
        <% episode.external_links.each do |platform, url| %>
          <%= link_to platform.to_s.humanize, url, class: "text-sm text-primary hover:text-primary/80 transition", target: "_blank" %>
        <% end %>
      </div>
    <% end %>
  </div>
</div>
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add podcast episode partials"
```

---

### Task 14: Create Learning Portfolio Page

**Files:**
- Create: `app/controllers/learning_items_controller.rb`
- Create: `app/views/learning_items/index.html.erb`
- Create: `app/views/learning_items/_detail.html.erb`
- Create: `spec/requests/learning_items_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/learning_items_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "LearningItems", type: :request do
  describe "GET /learning" do
    it "returns success" do
      get learning_portfolio_path
      expect(response).to have_http_status(:success)
    end

    it "displays learning items grouped by category" do
      create(:learning_item, name: "Ruby", category: "Languages")
      create(:learning_item, name: "Rails", category: "Frameworks")

      get learning_portfolio_path

      expect(response.body).to include("Ruby")
      expect(response.body).to include("Rails")
      expect(response.body).to include("Languages")
      expect(response.body).to include("Frameworks")
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/learning_items_spec.rb`
Expected: FAIL - controller not defined

**Step 3: Create controller**

Create `app/controllers/learning_items_controller.rb`:

```ruby
class LearningItemsController < ApplicationController
  def index
    @items_by_category = LearningItem.ordered.group_by(&:category)
  end

  def show
    @learning_item = LearningItem.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
```

**Step 4: Update routes**

Add to `config/routes.rb`:

```ruby
resources :learning_items, only: [:show]
```

**Step 5: Create index view**

Create `app/views/learning_items/index.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-3xl font-bold mb-2">Learning Portfolio</h1>
    <p class="text-muted mb-12">Things I'm learning, practicing, and know well.</p>

    <% if @items_by_category.any? %>
      <% @items_by_category.each do |category, items| %>
        <section class="mb-12">
          <h2 class="text-xl font-semibold mb-4 text-primary"><%= category %></h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <% items.each do |item| %>
              <%= turbo_frame_tag dom_id(item) do %>
                <div class="cursor-pointer" data-controller="expandable" data-action="click->expandable#toggle">
                  <%= render "learning_items/card", learning_item: item %>
                </div>
              <% end %>
            <% end %>
          </div>
        </section>
      <% end %>
    <% else %>
      <p class="text-muted">No learning items yet.</p>
    <% end %>
  </div>
</div>
```

**Step 6: Create detail partial**

Create `app/views/learning_items/_detail.html.erb`:

```erb
<div class="bg-background rounded-lg p-6 border border-primary/50">
  <div class="flex items-start justify-between">
    <div class="flex items-start space-x-3">
      <span class="text-3xl"><%= learning_item.icon %></span>
      <div>
        <h3 class="text-lg font-semibold"><%= learning_item.name %></h3>
        <p class="text-sm text-muted"><%= learning_item.category %></p>
      </div>
    </div>
    <button class="text-muted hover:text-text" data-action="click->expandable#collapse">
      <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
  </div>

  <% if learning_item.description.present? %>
    <p class="mt-4 text-muted"><%= learning_item.description %></p>
  <% end %>

  <div class="mt-4 flex flex-wrap gap-2">
    <span class="inline-block px-2 py-1 text-xs rounded-full
      <%= case learning_item.status
          when 'learning' then 'bg-primary/20 text-primary'
          when 'practicing' then 'bg-yellow-500/20 text-yellow-400'
          when 'comfortable' then 'bg-secondary/20 text-secondary'
          when 'expert' then 'bg-purple-500/20 text-purple-400'
          end %>">
      <%= learning_item.status.humanize %>
    </span>

    <% if learning_item.started_at.present? %>
      <span class="text-xs text-muted">
        Started <%= time_ago_in_words(learning_item.started_at) %> ago
      </span>
    <% end %>
  </div>

  <% if learning_item.resources.present? && learning_item.resources.any? %>
    <div class="mt-4">
      <h4 class="text-sm font-medium mb-2">Resources</h4>
      <ul class="space-y-1">
        <% learning_item.resources.each do |resource| %>
          <li>
            <%= link_to resource['title'], resource['url'], class: "text-sm text-primary hover:text-primary/80", target: "_blank" %>
          </li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <% if learning_item.projects.present? && learning_item.projects.any? %>
    <div class="mt-4">
      <h4 class="text-sm font-medium mb-2">Related Projects</h4>
      <ul class="space-y-1">
        <% learning_item.projects.each do |project| %>
          <li>
            <%= link_to project['name'], project['url'], class: "text-sm text-primary hover:text-primary/80", target: "_blank" %>
          </li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <% if learning_item.notes.present? %>
    <div class="mt-4 p-4 bg-surface rounded-lg">
      <h4 class="text-sm font-medium mb-2">Notes</h4>
      <div class="prose prose-invert prose-sm max-w-none">
        <%= simple_format(learning_item.notes) %>
      </div>
    </div>
  <% end %>
</div>
```

**Step 7: Run tests**

Run: `bundle exec rspec spec/requests/learning_items_spec.rb`
Expected: PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: add learning portfolio page with expandable cards"
```

---

### Task 15: Create Podcast Page

**Files:**
- Create: `app/controllers/podcast_episodes_controller.rb`
- Create: `app/views/podcast_episodes/index.html.erb`
- Create: `spec/requests/podcast_episodes_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/podcast_episodes_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "PodcastEpisodes", type: :request do
  describe "GET /podcast" do
    it "returns success" do
      get podcast_path
      expect(response).to have_http_status(:success)
    end

    it "displays episodes newest first" do
      old = create(:podcast_episode, title: "Old Episode", published_at: 1.week.ago)
      new_ep = create(:podcast_episode, title: "New Episode", published_at: 1.day.ago)

      get podcast_path

      expect(response.body.index("New Episode")).to be < response.body.index("Old Episode")
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: FAIL - controller not defined

**Step 3: Create controller**

Create `app/controllers/podcast_episodes_controller.rb`:

```ruby
class PodcastEpisodesController < ApplicationController
  def index
    @episodes = PodcastEpisode.published.newest_first
  end
end
```

**Step 4: Create index view**

Create `app/views/podcast_episodes/index.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-3xl font-bold mb-2">Podcast</h1>
    <p class="text-muted mb-12">Conversations about software, learning, and building things.</p>

    <% if @episodes.any? %>
      <div class="space-y-6">
        <% @episodes.each do |episode| %>
          <%= render "podcast_episodes/episode", episode: episode %>
        <% end %>
      </div>
    <% else %>
      <p class="text-muted">No episodes yet. Check back soon!</p>
    <% end %>
  </div>
</div>
```

**Step 5: Run tests**

Run: `bundle exec rspec spec/requests/podcast_episodes_spec.rb`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add podcast page with episode list"
```

---

## Phase 6: RSS Blog Integration

### Task 16: Add RSS Feed Fetching

**Files:**
- Create: `app/services/blog_feed_service.rb`
- Create: `app/controllers/blog_posts_controller.rb`
- Create: `app/views/blog_posts/_latest.html.erb`
- Modify: `config/routes.rb`
- Create: `spec/services/blog_feed_service_spec.rb`

**Step 1: Write failing test**

Create `spec/services/blog_feed_service_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe BlogFeedService do
  describe '.fetch_latest' do
    it 'returns nil when feed is unavailable' do
      allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('404', nil))

      result = BlogFeedService.fetch_latest

      expect(result).to be_nil
    end

    it 'parses RSS feed and returns latest post' do
      rss_content = <<~RSS
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Test Post</title>
              <link>https://blog.example.com/test</link>
              <description>This is a test post</description>
              <pubDate>Mon, 01 Jan 2024 00:00:00 +0000</pubDate>
            </item>
          </channel>
        </rss>
      RSS

      allow(URI).to receive(:open).and_return(StringIO.new(rss_content))

      result = BlogFeedService.fetch_latest

      expect(result[:title]).to eq('Test Post')
      expect(result[:url]).to eq('https://blog.example.com/test')
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/blog_feed_service_spec.rb`
Expected: FAIL - uninitialized constant BlogFeedService

**Step 3: Create service**

Create `app/services/blog_feed_service.rb`:

```ruby
require 'rss'
require 'open-uri'

class BlogFeedService
  FEED_URL = ENV.fetch('BLOG_RSS_URL', 'https://blog.example.com/feed.xml')
  CACHE_KEY = 'latest_blog_post'
  CACHE_DURATION = 15.minutes

  def self.fetch_latest
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_from_feed
    end
  end

  def self.fetch_from_feed
    content = URI.open(FEED_URL, read_timeout: 5).read
    feed = RSS::Parser.parse(content, false)

    return nil unless feed&.items&.any?

    item = feed.items.first
    {
      title: item.title,
      url: item.link,
      description: truncate_html(item.description),
      published_at: item.pubDate
    }
  rescue OpenURI::HTTPError, SocketError, RSS::Error, Timeout::Error => e
    Rails.logger.warn "Failed to fetch blog feed: #{e.message}"
    nil
  end

  def self.truncate_html(html, length: 200)
    return nil if html.nil?

    text = ActionController::Base.helpers.strip_tags(html)
    ActionController::Base.helpers.truncate(text, length: length)
  end
end
```

**Step 4: Create controller**

Create `app/controllers/blog_posts_controller.rb`:

```ruby
class BlogPostsController < ApplicationController
  def latest
    @post = BlogFeedService.fetch_latest

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'blog_posts/latest', locals: { post: @post } }
    end
  end
end
```

**Step 5: Create partial**

Create `app/views/blog_posts/_latest.html.erb`:

```erb
<% if post.present? %>
  <a href="<%= post[:url] %>" target="_blank" class="block bg-background rounded-lg p-6 border border-muted/20 hover:border-primary/50 transition">
    <span class="text-sm text-muted">
      <%= post[:published_at]&.strftime("%B %d, %Y") %>
    </span>
    <h3 class="text-lg font-semibold mt-1 mb-2 text-text"><%= post[:title] %></h3>
    <p class="text-muted text-sm"><%= post[:description] %></p>
    <span class="inline-block mt-3 text-primary text-sm">Read more →</span>
  </a>
<% else %>
  <div class="bg-background rounded-lg p-6 border border-muted/20">
    <p class="text-muted">Unable to load latest blog post.</p>
  </div>
<% end %>
```

**Step 6: Create Turbo Stream response**

Create `app/views/blog_posts/latest.turbo_stream.erb`:

```erb
<%= turbo_stream.replace "latest_blog_post" do %>
  <%= render "blog_posts/latest", post: @post %>
<% end %>
```

**Step 7: Add route**

Add to `config/routes.rb`:

```ruby
get "blog/latest", to: "blog_posts#latest", as: :latest_blog_post
```

**Step 8: Run tests**

Run: `bundle exec rspec spec/services/blog_feed_service_spec.rb`
Expected: PASS

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: add RSS blog feed integration with caching"
```

---

## Phase 7: Admin Dashboard

### Task 17: Create Admin Dashboard

**Files:**
- Create: `app/controllers/admin/dashboard_controller.rb`
- Create: `app/views/admin/dashboard/index.html.erb`
- Modify: `config/routes.rb`
- Create: `spec/requests/admin/dashboard_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/admin/dashboard_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    context "when not signed in" do
      it "redirects to sign in" do
        get admin_dashboard_path
        expect(response).to redirect_to(new_writer_session_path)
      end
    end

    context "when signed in" do
      let(:writer) { create(:writer) }

      before { sign_in writer }

      it "returns success" do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
```

**Step 2: Add Devise test helpers**

Add to `spec/rails_helper.rb`:

```ruby
config.include Devise::Test::IntegrationHelpers, type: :request
```

**Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/dashboard_spec.rb`
Expected: FAIL - route not defined

**Step 4: Create controller**

Create `app/controllers/admin/dashboard_controller.rb`:

```ruby
module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_writer!

    def index
      @learning_items = LearningItem.ordered
      @podcast_episodes = PodcastEpisode.newest_first
    end
  end
end
```

**Step 5: Add routes**

Update `config/routes.rb`:

```ruby
namespace :admin do
  get "/", to: "dashboard#index", as: :dashboard
end
```

**Step 6: Create view**

Create `app/views/admin/dashboard/index.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-3xl font-bold mb-8">Dashboard</h1>

    <!-- Learning Items Section -->
    <section class="mb-12">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-semibold">Learning Items</h2>
        <%= link_to "New Item", new_admin_learning_item_path, class: "px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/80 transition" %>
      </div>

      <div class="bg-surface rounded-lg border border-muted/20 overflow-hidden">
        <table class="w-full">
          <thead class="bg-background">
            <tr>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">Name</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">Category</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">Status</th>
              <th class="px-4 py-3 text-right text-sm font-medium text-muted">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-muted/20">
            <% @learning_items.each do |item| %>
              <tr>
                <td class="px-4 py-3">
                  <span class="mr-2"><%= item.icon %></span>
                  <%= item.name %>
                </td>
                <td class="px-4 py-3 text-muted"><%= item.category %></td>
                <td class="px-4 py-3"><%= item.status.humanize %></td>
                <td class="px-4 py-3 text-right">
                  <%= link_to "Edit", edit_admin_learning_item_path(item), class: "text-primary hover:text-primary/80" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </section>

    <!-- Podcast Episodes Section -->
    <section>
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-semibold">Podcast Episodes</h2>
        <%= link_to "New Episode", new_admin_podcast_episode_path, class: "px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/80 transition" %>
      </div>

      <div class="bg-surface rounded-lg border border-muted/20 overflow-hidden">
        <table class="w-full">
          <thead class="bg-background">
            <tr>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">#</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">Title</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-muted">Published</th>
              <th class="px-4 py-3 text-right text-sm font-medium text-muted">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-muted/20">
            <% @podcast_episodes.each do |episode| %>
              <tr>
                <td class="px-4 py-3 text-muted"><%= episode.episode_number %></td>
                <td class="px-4 py-3"><%= episode.title %></td>
                <td class="px-4 py-3 text-muted"><%= episode.published_at&.strftime("%b %d, %Y") %></td>
                <td class="px-4 py-3 text-right">
                  <%= link_to "Edit", edit_admin_podcast_episode_path(episode), class: "text-primary hover:text-primary/80" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</div>
```

**Step 7: Run tests**

Run: `bundle exec rspec spec/requests/admin/dashboard_spec.rb`
Expected: PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: add admin dashboard with content overview"
```

---

### Task 18: Create Admin Learning Items CRUD

**Files:**
- Create: `app/controllers/admin/learning_items_controller.rb`
- Create: `app/views/admin/learning_items/new.html.erb`
- Create: `app/views/admin/learning_items/edit.html.erb`
- Create: `app/views/admin/learning_items/_form.html.erb`
- Modify: `config/routes.rb`
- Create: `spec/requests/admin/learning_items_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/admin/learning_items_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Admin::LearningItems", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/learning_items/new" do
    it "returns success" do
      get new_admin_learning_item_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/learning_items" do
    it "creates a learning item" do
      expect {
        post admin_learning_items_path, params: {
          learning_item: {
            name: "Ruby",
            category: "Languages",
            status: "learning",
            icon: "💎"
          }
        }
      }.to change(LearningItem, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "PATCH /admin/learning_items/:id" do
    let(:item) { create(:learning_item) }

    it "updates the learning item" do
      patch admin_learning_item_path(item), params: {
        learning_item: { name: "Updated Name" }
      }

      expect(item.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /admin/learning_items/:id" do
    let!(:item) { create(:learning_item) }

    it "deletes the learning item" do
      expect {
        delete admin_learning_item_path(item)
      }.to change(LearningItem, :count).by(-1)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/learning_items_spec.rb`
Expected: FAIL - route not defined

**Step 3: Create controller**

Create `app/controllers/admin/learning_items_controller.rb`:

```ruby
module Admin
  class LearningItemsController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_learning_item, only: [:edit, :update, :destroy]

    def new
      @learning_item = LearningItem.new
    end

    def create
      @learning_item = LearningItem.new(learning_item_params)
      @learning_item.source = 'admin'

      if @learning_item.save
        redirect_to admin_dashboard_path, notice: "Learning item created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @learning_item.update(learning_item_params)
        redirect_to admin_dashboard_path, notice: "Learning item updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @learning_item.destroy
      redirect_to admin_dashboard_path, notice: "Learning item deleted."
    end

    private

    def set_learning_item
      @learning_item = LearningItem.find(params[:id])
    end

    def learning_item_params
      params.require(:learning_item).permit(
        :name, :icon, :category, :status, :description,
        :started_at, :notes, :position
      )
    end
  end
end
```

**Step 4: Add routes**

Update `config/routes.rb` inside the admin namespace:

```ruby
namespace :admin do
  get "/", to: "dashboard#index", as: :dashboard
  resources :learning_items, except: [:index, :show]
  resources :podcast_episodes, except: [:index, :show]
end
```

**Step 5: Create form partial**

Create `app/views/admin/learning_items/_form.html.erb`:

```erb
<%= form_with model: [:admin, learning_item], class: "space-y-6" do |f| %>
  <% if learning_item.errors.any? %>
    <div class="bg-red-500/20 text-red-400 px-4 py-3 rounded-lg">
      <ul class="list-disc list-inside">
        <% learning_item.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div>
      <%= f.label :name, class: "block text-sm font-medium mb-2" %>
      <%= f.text_field :name, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :icon, "Icon (emoji)", class: "block text-sm font-medium mb-2" %>
      <%= f.text_field :icon, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :category, class: "block text-sm font-medium mb-2" %>
      <%= f.text_field :category, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary", list: "categories" %>
      <datalist id="categories">
        <option value="Languages">
        <option value="Frameworks">
        <option value="DevOps">
        <option value="Concepts">
        <option value="Tools">
      </datalist>
    </div>

    <div>
      <%= f.label :status, class: "block text-sm font-medium mb-2" %>
      <%= f.select :status, LearningItem.statuses.keys.map { |s| [s.humanize, s] }, {}, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :started_at, class: "block text-sm font-medium mb-2" %>
      <%= f.date_field :started_at, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :position, class: "block text-sm font-medium mb-2" %>
      <%= f.number_field :position, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>
  </div>

  <div>
    <%= f.label :description, class: "block text-sm font-medium mb-2" %>
    <%= f.text_area :description, rows: 3, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
  </div>

  <div>
    <%= f.label :notes, "Notes (Markdown)", class: "block text-sm font-medium mb-2" %>
    <%= f.text_area :notes, rows: 5, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary font-mono text-sm" %>
  </div>

  <div class="flex gap-4">
    <%= f.submit class: "px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/80 transition cursor-pointer" %>
    <%= link_to "Cancel", admin_dashboard_path, class: "px-6 py-2 border border-muted/20 rounded-lg hover:border-muted transition" %>
  </div>
<% end %>
```

**Step 6: Create new view**

Create `app/views/admin/learning_items/new.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-2xl font-bold mb-8">New Learning Item</h1>
    <%= render "form", learning_item: @learning_item %>
  </div>
</div>
```

**Step 7: Create edit view**

Create `app/views/admin/learning_items/edit.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-bold">Edit Learning Item</h1>
      <%= button_to "Delete", admin_learning_item_path(@learning_item), method: :delete, data: { turbo_confirm: "Are you sure?" }, class: "text-red-400 hover:text-red-300" %>
    </div>
    <%= render "form", learning_item: @learning_item %>
  </div>
</div>
```

**Step 8: Run tests**

Run: `bundle exec rspec spec/requests/admin/learning_items_spec.rb`
Expected: PASS

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: add admin CRUD for learning items"
```

---

### Task 19: Create Admin Podcast Episodes CRUD

**Files:**
- Create: `app/controllers/admin/podcast_episodes_controller.rb`
- Create: `app/views/admin/podcast_episodes/new.html.erb`
- Create: `app/views/admin/podcast_episodes/edit.html.erb`
- Create: `app/views/admin/podcast_episodes/_form.html.erb`
- Create: `spec/requests/admin/podcast_episodes_spec.rb`

**Step 1: Write failing test**

Create `spec/requests/admin/podcast_episodes_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Admin::PodcastEpisodes", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/podcast_episodes/new" do
    it "returns success" do
      get new_admin_podcast_episode_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/podcast_episodes" do
    it "creates a podcast episode" do
      expect {
        post admin_podcast_episodes_path, params: {
          podcast_episode: {
            title: "New Episode",
            episode_number: 1,
            description: "A great episode",
            published_at: Date.today
          }
        }
      }.to change(PodcastEpisode, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "PATCH /admin/podcast_episodes/:id" do
    let(:episode) { create(:podcast_episode) }

    it "updates the podcast episode" do
      patch admin_podcast_episode_path(episode), params: {
        podcast_episode: { title: "Updated Title" }
      }

      expect(episode.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /admin/podcast_episodes/:id" do
    let!(:episode) { create(:podcast_episode) }

    it "deletes the podcast episode" do
      expect {
        delete admin_podcast_episode_path(episode)
      }.to change(PodcastEpisode, :count).by(-1)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/podcast_episodes_spec.rb`
Expected: FAIL - controller not defined

**Step 3: Create controller**

Create `app/controllers/admin/podcast_episodes_controller.rb`:

```ruby
module Admin
  class PodcastEpisodesController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_podcast_episode, only: [:edit, :update, :destroy]

    def new
      @podcast_episode = PodcastEpisode.new
    end

    def create
      @podcast_episode = PodcastEpisode.new(podcast_episode_params)

      if @podcast_episode.save
        redirect_to admin_dashboard_path, notice: "Episode created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @podcast_episode.update(podcast_episode_params)
        redirect_to admin_dashboard_path, notice: "Episode updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @podcast_episode.destroy
      redirect_to admin_dashboard_path, notice: "Episode deleted."
    end

    private

    def set_podcast_episode
      @podcast_episode = PodcastEpisode.find(params[:id])
    end

    def podcast_episode_params
      params.require(:podcast_episode).permit(
        :title, :description, :episode_number, :published_at, :embed_code
      )
    end
  end
end
```

**Step 4: Create form partial**

Create `app/views/admin/podcast_episodes/_form.html.erb`:

```erb
<%= form_with model: [:admin, podcast_episode], class: "space-y-6" do |f| %>
  <% if podcast_episode.errors.any? %>
    <div class="bg-red-500/20 text-red-400 px-4 py-3 rounded-lg">
      <ul class="list-disc list-inside">
        <% podcast_episode.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div class="md:col-span-2">
      <%= f.label :title, class: "block text-sm font-medium mb-2" %>
      <%= f.text_field :title, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :episode_number, class: "block text-sm font-medium mb-2" %>
      <%= f.number_field :episode_number, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>

    <div>
      <%= f.label :published_at, class: "block text-sm font-medium mb-2" %>
      <%= f.date_field :published_at, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
    </div>
  </div>

  <div>
    <%= f.label :description, class: "block text-sm font-medium mb-2" %>
    <%= f.text_area :description, rows: 4, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary" %>
  </div>

  <div>
    <%= f.label :embed_code, "Embed Code (from Spotify, etc.)", class: "block text-sm font-medium mb-2" %>
    <%= f.text_area :embed_code, rows: 4, class: "w-full px-4 py-2 bg-background border border-muted/20 rounded-lg focus:border-primary focus:ring-1 focus:ring-primary font-mono text-sm", placeholder: '<iframe src="https://open.spotify.com/embed/..."></iframe>' %>
  </div>

  <div class="flex gap-4">
    <%= f.submit class: "px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/80 transition cursor-pointer" %>
    <%= link_to "Cancel", admin_dashboard_path, class: "px-6 py-2 border border-muted/20 rounded-lg hover:border-muted transition" %>
  </div>
<% end %>
```

**Step 5: Create new view**

Create `app/views/admin/podcast_episodes/new.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-2xl font-bold mb-8">New Podcast Episode</h1>
    <%= render "form", podcast_episode: @podcast_episode %>
  </div>
</div>
```

**Step 6: Create edit view**

Create `app/views/admin/podcast_episodes/edit.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-bold">Edit Episode</h1>
      <%= button_to "Delete", admin_podcast_episode_path(@podcast_episode), method: :delete, data: { turbo_confirm: "Are you sure?" }, class: "text-red-400 hover:text-red-300" %>
    </div>
    <%= render "form", podcast_episode: @podcast_episode %>
  </div>
</div>
```

**Step 7: Run tests**

Run: `bundle exec rspec spec/requests/admin/podcast_episodes_spec.rb`
Expected: PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: add admin CRUD for podcast episodes"
```

---

## Phase 8: YAML Seeding

### Task 20: Create YAML Seed Infrastructure

**Files:**
- Create: `db/seeds/learning_items.yml`
- Create: `db/seeds/podcast_episodes.yml`
- Modify: `db/seeds.rb`
- Create: `lib/tasks/seed_from_yaml.rake`

**Step 1: Create learning items YAML**

Create `db/seeds/learning_items.yml`:

```yaml
- name: Ruby
  icon: "💎"
  category: Languages
  status: comfortable
  description: Primary backend language, love its expressiveness
  started_at: 2018-01-01
  position: 1
  resources:
    - title: Ruby Documentation
      url: https://ruby-doc.org
  projects:
    - name: This site
      url: https://github.com/pablocm90/learning-port

- name: Rails
  icon: "🛤️"
  category: Frameworks
  status: comfortable
  description: Full-stack web framework of choice
  started_at: 2018-06-01
  position: 2
  resources:
    - title: Rails Guides
      url: https://guides.rubyonrails.org

- name: Hotwire
  icon: "⚡"
  category: Frameworks
  status: learning
  description: Modern Rails frontend approach with Turbo and Stimulus
  started_at: 2024-01-01
  position: 3
```

**Step 2: Create podcast episodes YAML**

Create `db/seeds/podcast_episodes.yml`:

```yaml
# Add your episodes here
# - title: "Episode Title"
#   episode_number: 1
#   description: "Episode description"
#   published_at: 2024-01-01
#   embed_code: '<iframe src="..."></iframe>'
#   external_links:
#     spotify: "https://spotify.com/..."
#     apple: "https://podcasts.apple.com/..."
```

**Step 3: Update seeds.rb**

Replace `db/seeds.rb`:

```ruby
# Create admin writer
Writer.find_or_create_by!(email: 'admin@example.com') do |writer|
  writer.name = 'Pablo'
  writer.password = 'changeme123'
  writer.bio = 'Software developer and lifelong learner.'
end
puts "Admin writer ready: admin@example.com"

# Seed learning items from YAML
learning_items_file = Rails.root.join('db/seeds/learning_items.yml')
if File.exist?(learning_items_file)
  items = YAML.load_file(learning_items_file)
  items.each do |item_data|
    item = LearningItem.find_or_initialize_by(name: item_data['name'], source: 'yaml')
    item.assign_attributes(
      icon: item_data['icon'],
      category: item_data['category'],
      status: item_data['status'],
      description: item_data['description'],
      started_at: item_data['started_at'],
      position: item_data['position'],
      resources: item_data['resources'] || [],
      projects: item_data['projects'] || [],
      notes: item_data['notes'],
      source: 'yaml'
    )
    item.save!
    puts "Seeded learning item: #{item.name}"
  end
end

# Seed podcast episodes from YAML
episodes_file = Rails.root.join('db/seeds/podcast_episodes.yml')
if File.exist?(episodes_file)
  episodes = YAML.load_file(episodes_file)
  episodes&.each do |episode_data|
    next unless episode_data['title']

    episode = PodcastEpisode.find_or_initialize_by(episode_number: episode_data['episode_number'])
    episode.assign_attributes(
      title: episode_data['title'],
      description: episode_data['description'],
      published_at: episode_data['published_at'],
      embed_code: episode_data['embed_code'],
      external_links: episode_data['external_links'] || {}
    )
    episode.save!
    puts "Seeded episode: #{episode.title}"
  end
end

puts "Seeding complete!"
```

**Step 4: Test seeding**

```bash
bin/rails db:seed
```

Expected: Items seeded successfully

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add YAML seeding for learning items and episodes"
```

---

## Phase 9: Final Polish

### Task 21: Run Full Test Suite

**Step 1: Run all tests**

```bash
bundle exec rspec
```

Expected: All tests pass

**Step 2: Fix any failures**

Address any failing tests before proceeding.

**Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: address test failures"
```

---

### Task 22: Update Blog Link and Configuration

**Files:**
- Modify: `app/views/shared/_navbar.html.erb`
- Modify: `app/views/shared/_footer.html.erb`
- Create: `.env.example`

**Step 1: Create environment example file**

Create `.env.example`:

```
BLOG_RSS_URL=https://blog.yoursite.com/feed.xml
```

**Step 2: Update navbar with actual blog URL placeholder**

Update the blog link in `_navbar.html.erb` to use an environment variable or config:

```erb
<%= link_to "Blog", ENV.fetch('BLOG_URL', 'https://blog.example.com'), class: "text-muted hover:text-text transition", target: "_blank" %>
```

**Step 3: Update footer contact and social links**

Update `_footer.html.erb` with your actual links (or ENV variables).

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: add environment configuration for external links"
```

---

### Task 23: Final Verification

**Step 1: Start server and verify pages**

```bash
bin/rails server
```

Verify:
- [ ] Home page loads with all sections
- [ ] Learning portfolio page shows items by category
- [ ] Podcast page shows episodes
- [ ] Admin login works
- [ ] Admin can create/edit/delete learning items
- [ ] Admin can create/edit/delete episodes
- [ ] Mobile navigation works
- [ ] Footer links work

**Step 2: Commit any final fixes**

```bash
git add -A
git commit -m "chore: final polish and verification"
```

---

## Summary

This plan creates a complete Rails 8 personal site with:

1. **Tech Stack**: Ruby 3.3, Rails 8, Hotwire, Tailwind CSS 4, SQLite
2. **Authentication**: Devise with admin-only access
3. **Models**: Writer, LearningItem, PodcastEpisode
4. **Public Pages**: Home, Learning Portfolio, Podcast
5. **Admin**: Dashboard with CRUD for all content
6. **Features**: RSS blog integration, YAML seeding, embedded podcast players
7. **Testing**: RSpec with full request specs

Total tasks: 23
Estimated commits: 20+
