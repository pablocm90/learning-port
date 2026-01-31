# Paint Drip Learning Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the linear learning portfolio with a paint drip visualization inspired by Kent Beck's concept.

**Architecture:** Two new models (Category, LearningMoment) replace LearningItem. A Stimulus controller handles drip expansion. SVG-based organic shapes create the paint aesthetic. Drip depth is calculated from weighted engagement types and time span.

**Tech Stack:** Rails 8.0, Tailwind CSS, Stimulus, Turbo, RSpec, FactoryBot

---

## Task 1: Create Category Model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_categories.rb`
- Create: `app/models/category.rb`
- Create: `spec/models/category_spec.rb`
- Create: `spec/factories/categories.rb`

**Step 1: Write the failing test**

Create `spec/models/category_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:learning_moments).dependent(:destroy) }
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:category, position: 2)
      cat1 = create(:category, position: 1)

      expect(Category.ordered).to eq([cat1, cat2])
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: FAIL with "uninitialized constant Category"

**Step 3: Create the migration**

Run: `bin/rails generate migration CreateCategories name:string position:integer`

Edit the generated migration to:

```ruby
class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :categories, :name, unique: true
  end
end
```

**Step 4: Run the migration**

Run: `bin/rails db:migrate`

**Step 5: Create the model**

Create `app/models/category.rb`:

```ruby
class Category < ApplicationRecord
  has_many :learning_moments, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
end
```

**Step 6: Create the factory**

Create `spec/factories/categories.rb`:

```ruby
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    position { 0 }
  end
end
```

**Step 7: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: PASS (all green)

**Step 8: Commit**

```bash
git add db/migrate/*_create_categories.rb app/models/category.rb spec/models/category_spec.rb spec/factories/categories.rb
git commit -m "feat: add Category model for paint drip learning"
```

---

## Task 2: Create LearningMoment Model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_learning_moments.rb`
- Create: `app/models/learning_moment.rb`
- Create: `spec/models/learning_moment_spec.rb`
- Create: `spec/factories/learning_moments.rb`

**Step 1: Write the failing test**

Create `spec/models/learning_moment_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe LearningMoment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:engagement_type) }
    it { should validate_presence_of(:occurred_at) }
  end

  describe 'associations' do
    it { should belong_to(:category) }
  end

  describe 'enums' do
    it { should define_enum_for(:engagement_type).with_values(consumed: 0, experimented: 1, applied: 2, shared: 3) }
  end

  describe '#weight' do
    it 'returns 1 for consumed' do
      moment = build(:learning_moment, engagement_type: :consumed)
      expect(moment.weight).to eq(1)
    end

    it 'returns 2 for experimented' do
      moment = build(:learning_moment, engagement_type: :experimented)
      expect(moment.weight).to eq(2)
    end

    it 'returns 3 for applied' do
      moment = build(:learning_moment, engagement_type: :applied)
      expect(moment.weight).to eq(3)
    end

    it 'returns 4 for shared' do
      moment = build(:learning_moment, engagement_type: :shared)
      expect(moment.weight).to eq(4)
    end
  end

  describe 'scopes' do
    it 'orders chronologically (oldest first)' do
      new_moment = create(:learning_moment, occurred_at: 1.day.ago)
      old_moment = create(:learning_moment, occurred_at: 1.year.ago)

      expect(LearningMoment.chronological).to eq([old_moment, new_moment])
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/learning_moment_spec.rb`
Expected: FAIL with "uninitialized constant LearningMoment"

**Step 3: Create the migration**

Run: `bin/rails generate migration CreateLearningMoments category:references engagement_type:integer description:string url:string occurred_at:date`

Edit the generated migration to:

```ruby
class CreateLearningMoments < ActiveRecord::Migration[8.0]
  def change
    create_table :learning_moments do |t|
      t.references :category, null: false, foreign_key: true
      t.integer :engagement_type, null: false
      t.string :description, null: false
      t.string :url
      t.date :occurred_at, null: false

      t.timestamps
    end
  end
end
```

**Step 4: Run the migration**

Run: `bin/rails db:migrate`

**Step 5: Create the model**

Create `app/models/learning_moment.rb`:

```ruby
class LearningMoment < ApplicationRecord
  belongs_to :category

  enum :engagement_type, { consumed: 0, experimented: 1, applied: 2, shared: 3 }

  validates :description, presence: true
  validates :engagement_type, presence: true
  validates :occurred_at, presence: true

  scope :chronological, -> { order(:occurred_at) }

  WEIGHTS = { consumed: 1, experimented: 2, applied: 3, shared: 4 }.freeze

  def weight
    WEIGHTS[engagement_type.to_sym]
  end
end
```

**Step 6: Create the factory**

Create `spec/factories/learning_moments.rb`:

```ruby
FactoryBot.define do
  factory :learning_moment do
    category
    engagement_type { :consumed }
    description { Faker::Lorem.sentence }
    url { nil }
    occurred_at { Faker::Date.backward(days: 365) }
  end
end
```

**Step 7: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/learning_moment_spec.rb`
Expected: PASS (all green)

**Step 8: Commit**

```bash
git add db/migrate/*_create_learning_moments.rb app/models/learning_moment.rb spec/models/learning_moment_spec.rb spec/factories/learning_moments.rb
git commit -m "feat: add LearningMoment model with engagement types"
```

---

## Task 3: Add Drip Calculation Methods to Category

**Files:**
- Modify: `app/models/category.rb`
- Modify: `spec/models/category_spec.rb`

**Step 1: Write the failing tests**

Add to `spec/models/category_spec.rb`:

```ruby
describe '#weighted_score' do
  it 'returns sum of moment weights' do
    category = create(:category)
    create(:learning_moment, category: category, engagement_type: :consumed)   # 1
    create(:learning_moment, category: category, engagement_type: :applied)    # 3

    expect(category.weighted_score).to eq(4)
  end

  it 'returns 0 with no moments' do
    category = create(:category)
    expect(category.weighted_score).to eq(0)
  end
end

describe '#time_span_days' do
  it 'returns days between first and last moment' do
    category = create(:category)
    create(:learning_moment, category: category, occurred_at: 100.days.ago)
    create(:learning_moment, category: category, occurred_at: Date.today)

    expect(category.time_span_days).to eq(100)
  end

  it 'returns 0 with one moment' do
    category = create(:category)
    create(:learning_moment, category: category, occurred_at: Date.today)

    expect(category.time_span_days).to eq(0)
  end

  it 'returns 0 with no moments' do
    category = create(:category)
    expect(category.time_span_days).to eq(0)
  end
end

describe '#drip_depth' do
  it 'combines weighted score and time span' do
    category = create(:category)
    create(:learning_moment, category: category, engagement_type: :applied, occurred_at: 100.days.ago)
    create(:learning_moment, category: category, engagement_type: :consumed, occurred_at: Date.today)

    # weighted_score = 3 + 1 = 4
    # time_span_days = 100
    # drip_depth = 4 + (100 / 30.0) = 4 + 3.33 = 7.33
    expect(category.drip_depth).to be_within(0.1).of(7.33)
  end
end

describe '#engagement_types_present' do
  it 'returns array of engagement types that exist' do
    category = create(:category)
    create(:learning_moment, category: category, engagement_type: :consumed)
    create(:learning_moment, category: category, engagement_type: :applied)

    expect(category.engagement_types_present).to contain_exactly('consumed', 'applied')
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: FAIL with "undefined method `weighted_score'"

**Step 3: Implement the methods**

Update `app/models/category.rb`:

```ruby
class Category < ApplicationRecord
  has_many :learning_moments, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }

  def weighted_score
    learning_moments.sum(&:weight)
  end

  def time_span_days
    return 0 if learning_moments.count < 2

    dates = learning_moments.pluck(:occurred_at)
    (dates.max - dates.min).to_i
  end

  def drip_depth
    weighted_score + (time_span_days / 30.0)
  end

  def engagement_types_present
    learning_moments.distinct.pluck(:engagement_type)
  end
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: PASS (all green)

**Step 5: Commit**

```bash
git add app/models/category.rb spec/models/category_spec.rb
git commit -m "feat: add drip depth calculation to Category"
```

---

## Task 4: Create Paint Drip Stimulus Controller

**Files:**
- Create: `app/javascript/controllers/paint_drip_controller.js`
- Modify: `app/javascript/controllers/index.js`

**Step 1: Create the Stimulus controller**

Create `app/javascript/controllers/paint_drip_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drip", "moments"]
  static values = { expanded: String }

  connect() {
    this.expandedValue = ""
  }

  toggle(event) {
    const dripId = event.currentTarget.dataset.dripId

    if (this.expandedValue === dripId) {
      this.collapse()
    } else {
      this.expand(dripId)
    }
  }

  expand(dripId) {
    // Collapse any currently expanded drip
    this.collapse()

    // Expand the clicked drip
    this.expandedValue = dripId
    const drip = this.element.querySelector(`[data-drip-id="${dripId}"]`)
    const moments = drip?.querySelector('[data-paint-drip-target="moments"]')

    if (drip && moments) {
      drip.classList.add("expanded")
      moments.classList.remove("hidden")
      moments.classList.add("animate-expand")
    }
  }

  collapse() {
    if (!this.expandedValue) return

    const drip = this.element.querySelector(`[data-drip-id="${this.expandedValue}"]`)
    const moments = drip?.querySelector('[data-paint-drip-target="moments"]')

    if (drip && moments) {
      drip.classList.remove("expanded")
      moments.classList.add("hidden")
      moments.classList.remove("animate-expand")
    }

    this.expandedValue = ""
  }

  closeOnClickOutside(event) {
    if (!this.expandedValue) return

    const expandedDrip = this.element.querySelector(`[data-drip-id="${this.expandedValue}"]`)
    if (expandedDrip && !expandedDrip.contains(event.target)) {
      this.collapse()
    }
  }
}
```

**Step 2: Register the controller**

The controller will be auto-registered by stimulus-loading. Verify by checking `app/javascript/controllers/index.js` uses `eagerLoadControllersFrom`.

**Step 3: Commit**

```bash
git add app/javascript/controllers/paint_drip_controller.js
git commit -m "feat: add paint drip Stimulus controller for expand/collapse"
```

---

## Task 5: Create Learning Portfolio View with Paint Drip Visualization

**Files:**
- Create: `app/views/learning/_canvas.html.erb`
- Create: `app/views/learning/_drip.html.erb`
- Create: `app/views/learning/_droplet.html.erb`
- Create: `app/views/learning/index.html.erb`
- Modify: `app/controllers/learning_items_controller.rb` (rename to `learning_controller.rb`)

**Step 1: Create the controller**

Create `app/controllers/learning_controller.rb`:

```ruby
class LearningController < ApplicationController
  def index
    @categories = Category.ordered.includes(:learning_moments)
    @max_depth = @categories.map(&:drip_depth).max || 1
  end
end
```

**Step 2: Create the canvas partial**

Create `app/views/learning/_canvas.html.erb`:

```erb
<div class="paint-drip-canvas py-16" data-controller="paint-drip" data-action="click@window->paint-drip#closeOnClickOutside">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Brush Stroke -->
    <div class="brush-stroke relative h-16 bg-primary/80 rounded-t-sm mb-0" style="clip-path: polygon(0 30%, 2% 0, 8% 40%, 15% 10%, 25% 50%, 35% 5%, 45% 45%, 55% 15%, 65% 40%, 75% 0, 85% 35%, 92% 10%, 98% 45%, 100% 20%, 100% 100%, 0 100%);">
      <div class="absolute inset-0 flex items-end justify-around px-8 pb-2">
        <% categories.each do |category| %>
          <span class="text-white text-sm font-medium"><%= category.name %></span>
        <% end %>
      </div>
    </div>

    <!-- Drips Container -->
    <div class="drips-container flex justify-around px-8">
      <% categories.each do |category| %>
        <%= render "learning/drip", category: category, max_depth: max_depth %>
      <% end %>
    </div>
  </div>
</div>
```

**Step 3: Create the drip partial**

Create `app/views/learning/_drip.html.erb`:

```erb
<%
  depth_percentage = max_depth > 0 ? (category.drip_depth / max_depth * 100) : 0
  min_height = 60
  max_height = 400
  drip_height = min_height + (depth_percentage / 100.0 * (max_height - min_height))
  saturation = 70 + (depth_percentage / 100.0 * 30)
%>

<div class="drip-column flex flex-col items-center cursor-pointer transition-all duration-300 hover:scale-105"
     data-drip-id="<%= category.id %>"
     data-action="click->paint-drip#toggle">

  <!-- The Drip Shape -->
  <div class="drip relative"
       style="width: 48px; height: <%= drip_height.to_i %>px;">
    <svg viewBox="0 0 48 100" preserveAspectRatio="none" class="w-full h-full" style="filter: saturate(<%= saturation.to_i %>%);">
      <defs>
        <linearGradient id="drip-gradient-<%= category.id %>" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color: var(--color-primary); stop-opacity: 0.9;" />
          <stop offset="100%" style="stop-color: var(--color-primary); stop-opacity: 0.6;" />
        </linearGradient>
      </defs>
      <path d="M 0,0 L 48,0 L 46,85 Q 44,95 38,98 Q 24,105 10,98 Q 4,95 2,85 Z"
            fill="url(#drip-gradient-<%= category.id %>)" />
    </svg>

    <!-- Engagement Icons -->
    <div class="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-0.5">
      <% category.engagement_types_present.each do |type| %>
        <span class="text-xs opacity-80" title="<%= type.humanize %>">
          <%= case type
              when 'consumed' then '📖'
              when 'experimented' then '🧪'
              when 'applied' then '🔨'
              when 'shared' then '📣'
              end %>
        </span>
      <% end %>
    </div>
  </div>

  <!-- Expanded Moments (hidden by default) -->
  <div data-paint-drip-target="moments" class="hidden mt-4 w-64 bg-surface border border-muted/20 rounded-lg p-4 shadow-lg">
    <h3 class="font-semibold text-text mb-3"><%= category.name %></h3>
    <div class="space-y-2 max-h-80 overflow-y-auto">
      <% category.learning_moments.chronological.each do |moment| %>
        <%= render "learning/droplet", moment: moment %>
      <% end %>
    </div>
  </div>
</div>
```

**Step 4: Create the droplet partial**

Create `app/views/learning/_droplet.html.erb`:

```erb
<div class="droplet flex items-start gap-2 p-2 rounded bg-background/50">
  <span class="text-sm flex-shrink-0">
    <%= case moment.engagement_type
        when 'consumed' then '📖'
        when 'experimented' then '🧪'
        when 'applied' then '🔨'
        when 'shared' then '📣'
        end %>
  </span>
  <div class="flex-1 min-w-0">
    <p class="text-sm text-text"><%= moment.description %></p>
    <% if moment.url.present? %>
      <%= link_to "Link", moment.url, target: "_blank", rel: "noopener noreferrer", class: "text-xs text-primary hover:underline" %>
    <% end %>
    <p class="text-xs text-muted mt-1"><%= moment.occurred_at.strftime("%b %Y") %></p>
  </div>
</div>
```

**Step 5: Create the index view**

Create `app/views/learning/index.html.erb`:

```erb
<div class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 mb-12">
    <h1 class="text-3xl font-bold mb-2">How I Learn</h1>
    <p class="text-muted">
      Inspired by Kent Beck's <a href="https://tidyfirst.substack.com/p/paint-drip-people" target="_blank" rel="noopener noreferrer" class="text-primary hover:underline">paint drip people</a> concept.
      Drip depth reflects engagement intensity and time spent exploring each domain.
    </p>
  </div>

  <% if @categories.any? %>
    <%= render "learning/canvas", categories: @categories, max_depth: @max_depth %>
  <% else %>
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <p class="text-muted">No learning categories yet.</p>
    </div>
  <% end %>
</div>
```

**Step 6: Commit**

```bash
git add app/controllers/learning_controller.rb app/views/learning/
git commit -m "feat: add paint drip visualization views"
```

---

## Task 6: Update Routes

**Files:**
- Modify: `config/routes.rb`

**Step 1: Update routes**

Update `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :categories, except: [:show]
    resources :learning_moments, except: [:index, :show]
    resources :podcast_episodes, except: [:index, :show]
  end

  root "pages#home"

  get "learning", to: "learning#index", as: :learning_portfolio
  get "podcast", to: "podcast_episodes#index", as: :podcast
  get "blog/latest", to: "blog_posts#latest", as: :latest_blog_post
end
```

**Step 2: Commit**

```bash
git add config/routes.rb
git commit -m "feat: update routes for paint drip learning"
```

---

## Task 7: Create Admin Categories Controller

**Files:**
- Create: `app/controllers/admin/categories_controller.rb`
- Create: `app/views/admin/categories/_form.html.erb`
- Create: `app/views/admin/categories/new.html.erb`
- Create: `app/views/admin/categories/edit.html.erb`
- Create: `spec/requests/admin/categories_spec.rb`

**Step 1: Write the failing test**

Create `spec/requests/admin/categories_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Admin::Categories", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/categories/new" do
    it "returns success" do
      get new_admin_category_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/categories" do
    it "creates a new category" do
      expect {
        post admin_categories_path, params: { category: { name: "Agile", position: 1 } }
      }.to change(Category, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "GET /admin/categories/:id/edit" do
    it "returns success" do
      category = create(:category)
      get edit_admin_category_path(category)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/categories/:id" do
    it "updates the category" do
      category = create(:category, name: "Old Name")
      patch admin_category_path(category), params: { category: { name: "New Name" } }

      expect(category.reload.name).to eq("New Name")
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "DELETE /admin/categories/:id" do
    it "deletes the category" do
      category = create(:category)

      expect {
        delete admin_category_path(category)
      }.to change(Category, :count).by(-1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/categories_spec.rb`
Expected: FAIL with routing or controller error

**Step 3: Create the controller**

Create `app/controllers/admin/categories_controller.rb`:

```ruby
module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_category, only: [:edit, :update, :destroy]

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_dashboard_path, notice: "Category was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_dashboard_path, notice: "Category was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_dashboard_path, notice: "Category was successfully deleted."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :position)
    end
  end
end
```

**Step 4: Create the form partial**

Create `app/views/admin/categories/_form.html.erb`:

```erb
<%= form_with model: [:admin, category], class: "space-y-6" do |f| %>
  <% if category.errors.any? %>
    <div class="bg-red-500/10 border border-red-500/20 rounded p-4">
      <ul class="list-disc list-inside text-red-400 text-sm">
        <% category.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= f.label :name, class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.text_field :name, class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none" %>
  </div>

  <div>
    <%= f.label :position, class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.number_field :position, class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none" %>
    <p class="text-xs text-muted mt-1">Lower numbers appear first (left to right)</p>
  </div>

  <div class="flex gap-4">
    <%= f.submit class: "bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition cursor-pointer" %>
    <%= link_to "Cancel", admin_dashboard_path, class: "text-muted hover:text-text transition" %>
  </div>
<% end %>
```

**Step 5: Create new.html.erb**

Create `app/views/admin/categories/new.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-2xl font-bold text-text mb-8">New Category</h1>
  <%= render "form", category: @category %>
</div>
```

**Step 6: Create edit.html.erb**

Create `app/views/admin/categories/edit.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-2xl font-bold text-text mb-8">Edit Category</h1>
  <%= render "form", category: @category %>
</div>
```

**Step 7: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/admin/categories_spec.rb`
Expected: PASS (all green)

**Step 8: Commit**

```bash
git add app/controllers/admin/categories_controller.rb app/views/admin/categories/ spec/requests/admin/categories_spec.rb
git commit -m "feat: add admin categories controller and views"
```

---

## Task 8: Create Admin Learning Moments Controller

**Files:**
- Create: `app/controllers/admin/learning_moments_controller.rb`
- Create: `app/views/admin/learning_moments/_form.html.erb`
- Create: `app/views/admin/learning_moments/new.html.erb`
- Create: `app/views/admin/learning_moments/edit.html.erb`
- Create: `spec/requests/admin/learning_moments_spec.rb`

**Step 1: Write the failing test**

Create `spec/requests/admin/learning_moments_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Admin::LearningMoments", type: :request do
  let(:writer) { create(:writer) }
  let(:category) { create(:category) }

  before { sign_in writer }

  describe "GET /admin/learning_moments/new" do
    it "returns success" do
      get new_admin_learning_moment_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/learning_moments" do
    it "creates a new learning moment" do
      expect {
        post admin_learning_moments_path, params: {
          learning_moment: {
            category_id: category.id,
            engagement_type: "consumed",
            description: "Read a great book",
            occurred_at: Date.today
          }
        }
      }.to change(LearningMoment, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "GET /admin/learning_moments/:id/edit" do
    it "returns success" do
      moment = create(:learning_moment)
      get edit_admin_learning_moment_path(moment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/learning_moments/:id" do
    it "updates the learning moment" do
      moment = create(:learning_moment, description: "Old description")
      patch admin_learning_moment_path(moment), params: {
        learning_moment: { description: "New description" }
      }

      expect(moment.reload.description).to eq("New description")
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "DELETE /admin/learning_moments/:id" do
    it "deletes the learning moment" do
      moment = create(:learning_moment)

      expect {
        delete admin_learning_moment_path(moment)
      }.to change(LearningMoment, :count).by(-1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/admin/learning_moments_spec.rb`
Expected: FAIL

**Step 3: Create the controller**

Create `app/controllers/admin/learning_moments_controller.rb`:

```ruby
module Admin
  class LearningMomentsController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_learning_moment, only: [:edit, :update, :destroy]

    def new
      @learning_moment = LearningMoment.new
      @categories = Category.ordered
    end

    def create
      @learning_moment = LearningMoment.new(learning_moment_params)

      if @learning_moment.save
        redirect_to admin_dashboard_path, notice: "Learning moment was successfully created."
      else
        @categories = Category.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.ordered
    end

    def update
      if @learning_moment.update(learning_moment_params)
        redirect_to admin_dashboard_path, notice: "Learning moment was successfully updated."
      else
        @categories = Category.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @learning_moment.destroy
      redirect_to admin_dashboard_path, notice: "Learning moment was successfully deleted."
    end

    private

    def set_learning_moment
      @learning_moment = LearningMoment.find(params[:id])
    end

    def learning_moment_params
      params.require(:learning_moment).permit(:category_id, :engagement_type, :description, :url, :occurred_at)
    end
  end
end
```

**Step 4: Create the form partial**

Create `app/views/admin/learning_moments/_form.html.erb`:

```erb
<%= form_with model: [:admin, learning_moment], class: "space-y-6" do |f| %>
  <% if learning_moment.errors.any? %>
    <div class="bg-red-500/10 border border-red-500/20 rounded p-4">
      <ul class="list-disc list-inside text-red-400 text-sm">
        <% learning_moment.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= f.label :category_id, "Category", class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.collection_select :category_id, categories, :id, :name,
        { prompt: "Select a category" },
        { class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none" } %>
  </div>

  <div>
    <%= f.label :engagement_type, class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.select :engagement_type,
        LearningMoment.engagement_types.keys.map { |t| [t.humanize, t] },
        { prompt: "Select engagement type" },
        { class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none" } %>
    <p class="text-xs text-muted mt-1">
      📖 Consumed (read/watched) • 🧪 Experimented (tried once) • 🔨 Applied (real use) • 📣 Shared (taught others)
    </p>
  </div>

  <div>
    <%= f.label :description, class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.text_field :description, class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none", placeholder: "e.g., Kent Beck's XP book" %>
  </div>

  <div>
    <%= f.label :url, "Link (optional)", class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.url_field :url, class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none", placeholder: "https://..." %>
  </div>

  <div>
    <%= f.label :occurred_at, "When did this happen?", class: "block text-sm font-medium text-muted mb-1" %>
    <%= f.date_field :occurred_at, class: "w-full bg-background border border-muted/20 rounded px-3 py-2 text-text focus:border-primary focus:outline-none" %>
  </div>

  <div class="flex gap-4">
    <%= f.submit class: "bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition cursor-pointer" %>
    <%= link_to "Cancel", admin_dashboard_path, class: "text-muted hover:text-text transition" %>
  </div>
<% end %>
```

**Step 5: Create new.html.erb**

Create `app/views/admin/learning_moments/new.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-2xl font-bold text-text mb-8">New Learning Moment</h1>
  <%= render "form", learning_moment: @learning_moment, categories: @categories %>
</div>
```

**Step 6: Create edit.html.erb**

Create `app/views/admin/learning_moments/edit.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-2xl font-bold text-text mb-8">Edit Learning Moment</h1>
  <%= render "form", learning_moment: @learning_moment, categories: @categories %>
</div>
```

**Step 7: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/admin/learning_moments_spec.rb`
Expected: PASS

**Step 8: Commit**

```bash
git add app/controllers/admin/learning_moments_controller.rb app/views/admin/learning_moments/ spec/requests/admin/learning_moments_spec.rb
git commit -m "feat: add admin learning moments controller and views"
```

---

## Task 9: Update Admin Dashboard

**Files:**
- Modify: `app/controllers/admin/dashboard_controller.rb`
- Modify: `app/views/admin/dashboard/index.html.erb`

**Step 1: Update the controller**

Update `app/controllers/admin/dashboard_controller.rb`:

```ruby
module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_writer!

    def index
      @categories = Category.ordered.includes(:learning_moments)
      @podcast_episodes = PodcastEpisode.newest_first
    end
  end
end
```

**Step 2: Update the view**

Replace `app/views/admin/dashboard/index.html.erb`:

```erb
<div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-3xl font-bold text-text mb-8">Dashboard</h1>

  <!-- Categories Section -->
  <div class="mb-12">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-xl font-semibold text-text">Learning Categories</h2>
      <%= link_to "New Category", new_admin_category_path, class: "bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition" %>
    </div>

    <div class="bg-surface border border-muted/20 rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-muted/20">
        <thead class="bg-muted/10">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Position</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Name</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Moments</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-muted/20">
          <% @categories.each do |category| %>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= category.position %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-text"><%= category.name %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= category.learning_moments.count %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                <%= link_to "Edit", edit_admin_category_path(category), class: "text-primary hover:text-primary/80" %>
                <%= button_to "Delete", admin_category_path(category), method: :delete, class: "text-red-400 hover:text-red-300", form: { data: { turbo_confirm: "Are you sure?" } } %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Learning Moments Section -->
  <div class="mb-12">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-xl font-semibold text-text">Learning Moments</h2>
      <%= link_to "New Moment", new_admin_learning_moment_path, class: "bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition" %>
    </div>

    <div class="bg-surface border border-muted/20 rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-muted/20">
        <thead class="bg-muted/10">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Category</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Type</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Description</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Date</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-muted/20">
          <% @categories.each do |category| %>
            <% category.learning_moments.chronological.each do |moment| %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= category.name %></td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-muted">
                  <%= case moment.engagement_type
                      when 'consumed' then '📖'
                      when 'experimented' then '🧪'
                      when 'applied' then '🔨'
                      when 'shared' then '📣'
                      end %>
                  <%= moment.engagement_type.humanize %>
                </td>
                <td class="px-6 py-4 text-sm text-text max-w-xs truncate"><%= moment.description %></td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= moment.occurred_at.strftime("%b %Y") %></td>
                <td class="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                  <%= link_to "Edit", edit_admin_learning_moment_path(moment), class: "text-primary hover:text-primary/80" %>
                  <%= button_to "Delete", admin_learning_moment_path(moment), method: :delete, class: "text-red-400 hover:text-red-300", form: { data: { turbo_confirm: "Are you sure?" } } %>
                </td>
              </tr>
            <% end %>
          <% end %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Podcast Episodes Section -->
  <div>
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-xl font-semibold text-text">Podcast Episodes</h2>
      <%= link_to "New Episode", new_admin_podcast_episode_path, class: "bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition" %>
    </div>

    <div class="bg-surface border border-muted/20 rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-muted/20">
        <thead class="bg-muted/10">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">#</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Title</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Published</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-muted/20">
          <% @podcast_episodes.each do |episode| %>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= episode.episode_number %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-text"><%= episode.title %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-muted"><%= episode.published_at&.strftime("%b %d, %Y") %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <%= link_to "Edit", edit_admin_podcast_episode_path(episode), class: "text-primary hover:text-primary/80" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  </div>
</div>
```

**Step 3: Commit**

```bash
git add app/controllers/admin/dashboard_controller.rb app/views/admin/dashboard/index.html.erb
git commit -m "feat: update admin dashboard for categories and moments"
```

---

## Task 10: Update Homepage with Mini Paint Drip

**Files:**
- Modify: `app/controllers/pages_controller.rb`
- Modify: `app/views/pages/home.html.erb`
- Create: `app/views/learning/_mini_canvas.html.erb`

**Step 1: Update the pages controller**

Update `app/controllers/pages_controller.rb`:

```ruby
class PagesController < ApplicationController
  def home
    @latest_episode = PodcastEpisode.published.newest_first.first
    @active_categories = Category.ordered
                                 .includes(:learning_moments)
                                 .select { |c| c.learning_moments.any? }
                                 .sort_by { |c| c.learning_moments.maximum(:occurred_at) || Date.new(1970) }
                                 .reverse
                                 .first(4)
    @max_depth = @active_categories.map(&:drip_depth).max || 1
  end
end
```

**Step 2: Create the mini canvas partial**

Create `app/views/learning/_mini_canvas.html.erb`:

```erb
<div class="paint-drip-mini">
  <!-- Mini Brush Stroke -->
  <div class="brush-stroke-mini relative h-10 bg-primary/80 rounded-t-sm mb-0" style="clip-path: polygon(0 30%, 5% 0, 15% 50%, 30% 10%, 50% 45%, 70% 5%, 85% 40%, 95% 15%, 100% 35%, 100% 100%, 0 100%);">
    <div class="absolute inset-0 flex items-end justify-around px-4 pb-1">
      <% categories.each do |category| %>
        <span class="text-white text-xs font-medium truncate max-w-[80px]"><%= category.name %></span>
      <% end %>
    </div>
  </div>

  <!-- Mini Drips -->
  <div class="drips-container flex justify-around px-4">
    <% categories.each do |category| %>
      <%
        depth_percentage = max_depth > 0 ? (category.drip_depth / max_depth * 100) : 0
        min_height = 30
        max_height = 100
        drip_height = min_height + (depth_percentage / 100.0 * (max_height - min_height))
      %>
      <div class="drip-mini flex flex-col items-center">
        <svg viewBox="0 0 32 100" preserveAspectRatio="none" style="width: 32px; height: <%= drip_height.to_i %>px;">
          <path d="M 0,0 L 32,0 L 30,85 Q 28,95 24,98 Q 16,102 8,98 Q 4,95 2,85 Z"
                fill="var(--color-primary)" fill-opacity="0.7" />
        </svg>
        <div class="flex gap-0.5 mt-1">
          <% category.engagement_types_present.first(3).each do |type| %>
            <span class="text-[10px] opacity-70">
              <%= case type
                  when 'consumed' then '📖'
                  when 'experimented' then '🧪'
                  when 'applied' then '🔨'
                  when 'shared' then '📣'
                  end %>
            </span>
          <% end %>
        </div>
      </div>
    <% end %>
  </div>
</div>
```

**Step 3: Update homepage view**

Update the "Currently Learning" section in `app/views/pages/home.html.erb`:

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
      <h2 class="text-2xl font-semibold">How I Learn</h2>
      <%= link_to "See all ->", learning_portfolio_path, class: "text-primary hover:text-primary/80 transition" %>
    </div>

    <% if @active_categories.any? %>
      <%= render "learning/mini_canvas", categories: @active_categories, max_depth: @max_depth %>
    <% else %>
      <p class="text-muted">No learning moments yet.</p>
    <% end %>
  </div>
</section>

<!-- Latest Podcast Episode -->
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-semibold">Latest Episode</h2>
      <%= link_to "All episodes ->", podcast_path, class: "text-primary hover:text-primary/80 transition" %>
    </div>

    <% if @latest_episode %>
      <%= render "podcast_episodes/featured", episode: @latest_episode %>
    <% else %>
      <p class="text-muted">No episodes yet.</p>
    <% end %>
  </div>
</section>

<!-- Latest Blog Post (RSS) - placeholder for now -->
<section class="py-16 bg-surface">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-semibold">Latest from the Blog</h2>
      <%= link_to "Read more ->", ENV.fetch('BLOG_URL', 'https://blog.example.com'), class: "text-primary hover:text-primary/80 transition", target: "_blank" %>
    </div>

    <%= turbo_frame_tag "latest_blog_post", src: latest_blog_post_path, loading: :lazy do %>
      <div class="animate-pulse bg-background rounded-lg h-32"></div>
    <% end %>
  </div>
</section>
```

**Step 4: Commit**

```bash
git add app/controllers/pages_controller.rb app/views/pages/home.html.erb app/views/learning/_mini_canvas.html.erb
git commit -m "feat: add mini paint drip to homepage"
```

---

## Task 11: Update Request Specs for Learning Portfolio

**Files:**
- Create: `spec/requests/learning_spec.rb`
- Delete: `spec/requests/learning_items_spec.rb`

**Step 1: Create the new spec**

Create `spec/requests/learning_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Learning", type: :request do
  describe "GET /learning" do
    it "returns success" do
      get learning_portfolio_path
      expect(response).to have_http_status(:success)
    end

    it "displays categories with their drips" do
      category = create(:category, name: "Agile")
      create(:learning_moment, category: category, description: "Read XP book")

      get learning_portfolio_path

      expect(response.body).to include("Agile")
      expect(response.body).to include("How I Learn")
    end

    it "shows empty state when no categories" do
      get learning_portfolio_path

      expect(response.body).to include("No learning categories yet")
    end
  end
end
```

**Step 2: Run test to verify it passes**

Run: `bundle exec rspec spec/requests/learning_spec.rb`
Expected: PASS

**Step 3: Delete old spec**

Run: `rm spec/requests/learning_items_spec.rb`

**Step 4: Commit**

```bash
git add spec/requests/learning_spec.rb
git rm spec/requests/learning_items_spec.rb
git commit -m "test: update request specs for paint drip learning"
```

---

## Task 12: Remove Old LearningItem Files

**Files:**
- Delete: `app/models/learning_item.rb`
- Delete: `app/controllers/learning_items_controller.rb`
- Delete: `app/controllers/admin/learning_items_controller.rb`
- Delete: `app/views/learning_items/` (entire directory)
- Delete: `app/views/admin/learning_items/` (entire directory)
- Delete: `spec/models/learning_item_spec.rb`
- Delete: `spec/factories/learning_items.rb`
- Delete: `spec/requests/admin/learning_items_spec.rb`
- Delete: `db/seeds/learning_items.yml`
- Create: `db/migrate/TIMESTAMP_drop_learning_items.rb`

**Step 1: Create migration to drop old table**

Run: `bin/rails generate migration DropLearningItems`

Edit the migration:

```ruby
class DropLearningItems < ActiveRecord::Migration[8.0]
  def change
    drop_table :learning_items do |t|
      t.string :name
      t.string :icon
      t.string :category
      t.integer :status
      t.text :description
      t.date :started_at
      t.jsonb :resources, default: []
      t.text :notes
      t.jsonb :projects, default: []
      t.integer :position, default: 0
      t.string :source, default: 'admin'
      t.timestamps
    end
  end
end
```

**Step 2: Run migration**

Run: `bin/rails db:migrate`

**Step 3: Remove old files**

```bash
rm app/models/learning_item.rb
rm app/controllers/learning_items_controller.rb
rm app/controllers/admin/learning_items_controller.rb
rm -rf app/views/learning_items/
rm -rf app/views/admin/learning_items/
rm spec/models/learning_item_spec.rb
rm spec/factories/learning_items.rb
rm spec/requests/admin/learning_items_spec.rb
rm db/seeds/learning_items.yml
```

**Step 4: Run all tests to verify nothing is broken**

Run: `bundle exec rspec`
Expected: All tests pass

**Step 5: Commit**

```bash
git add db/migrate/*_drop_learning_items.rb
git add -A
git commit -m "chore: remove old LearningItem model and related files"
```

---

## Task 13: Create Seed Data

**Files:**
- Create: `db/seeds/categories.yml`
- Modify: `db/seeds.rb`

**Step 1: Create categories seed file**

Create `db/seeds/categories.yml`:

```yaml
- name: Agile
  position: 1
  moments:
    - engagement_type: consumed
      description: Read Agile Manifesto
      occurred_at: 2020-01-15
      url: https://agilemanifesto.org
    - engagement_type: experimented
      description: First sprint planning session
      occurred_at: 2020-03-01
    - engagement_type: applied
      description: Led retrospectives for 6 months
      occurred_at: 2021-06-15

- name: Collaborative Coding
  position: 2
  moments:
    - engagement_type: consumed
      description: Read Extreme Programming Explained
      occurred_at: 2021-02-10
    - engagement_type: experimented
      description: First pair programming session
      occurred_at: 2021-03-15
    - engagement_type: applied
      description: Regular ensemble programming at work
      occurred_at: 2022-01-01
    - engagement_type: shared
      description: Facilitated ensemble session for new team
      occurred_at: 2023-06-01

- name: TDD
  position: 3
  moments:
    - engagement_type: consumed
      description: "Watched Uncle Bob's TDD videos"
      occurred_at: 2019-06-01
    - engagement_type: experimented
      description: First red-green-refactor cycle
      occurred_at: 2019-07-01
    - engagement_type: applied
      description: TDD as default practice
      occurred_at: 2020-01-01
```

**Step 2: Update seeds.rb**

Update `db/seeds.rb` to load the new seed data:

```ruby
# Load categories and learning moments
categories_file = Rails.root.join("db/seeds/categories.yml")
if File.exist?(categories_file)
  categories_data = YAML.load_file(categories_file)
  categories_data.each do |cat_data|
    category = Category.find_or_create_by!(name: cat_data["name"]) do |c|
      c.position = cat_data["position"]
    end

    cat_data["moments"]&.each do |moment_data|
      category.learning_moments.find_or_create_by!(
        description: moment_data["description"],
        occurred_at: moment_data["occurred_at"]
      ) do |m|
        m.engagement_type = moment_data["engagement_type"]
        m.url = moment_data["url"]
      end
    end
  end
  puts "Loaded #{Category.count} categories with #{LearningMoment.count} learning moments"
end
```

**Step 3: Run seeds**

Run: `bin/rails db:seed`

**Step 4: Commit**

```bash
git add db/seeds/categories.yml db/seeds.rb
git commit -m "feat: add seed data for paint drip categories and moments"
```

---

## Task 14: Final Verification

**Step 1: Run all tests**

Run: `bundle exec rspec`
Expected: All tests pass

**Step 2: Start the server and manually verify**

Run: `bin/rails server`

Verify:
1. Homepage shows mini paint drip with active categories
2. `/learning` shows full paint drip visualization
3. Clicking a drip expands to show moments
4. Admin dashboard shows categories and moments
5. Can create/edit/delete categories and moments

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete paint drip learning implementation"
```
