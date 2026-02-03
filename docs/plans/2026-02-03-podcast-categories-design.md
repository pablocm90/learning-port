# Podcast Categories & Seed Data Design

## Context

The "A Junior, A Senior and I" podcast has 27 episodes hosted on Riverside.fm. The site already has a `PodcastEpisode` model with CRUD and a seed infrastructure. This design adds topic-based categorization and prepopulates all episodes from the RSS feed.

## Data Model

### New model: `PodcastCategory`

| Field    | Type    | Constraints              |
|----------|---------|--------------------------|
| name     | string  | required, unique         |
| position | integer | for display ordering     |

### New join table: `podcast_episode_categories`

| Field               | Type       | Constraints                          |
|---------------------|------------|--------------------------------------|
| podcast_episode_id  | references | foreign key, not null                |
| podcast_category_id | references | foreign key, not null                |
|                     |            | unique index on both columns jointly |

### Associations

- `PodcastEpisode has_many :podcast_categories, through: :podcast_episode_categories`
- `PodcastCategory has_many :podcast_episodes, through: :podcast_episode_categories`

### Existing model changes

No schema changes to `podcast_episodes`. Only association additions to the model file.

## Categories

| Position | Name                   |
|----------|------------------------|
| 1        | Software Practices     |
| 2        | Teams & Collaboration  |
| 3        | Career & Learning      |
| 4        | Tech Meets Business    |
| 5        | Technology Deep Dives  |

## Episode-to-Category Assignments

| # | Title | Categories |
|---|-------|------------|
| 1 | On Power and Responsibility | Career & Learning |
| 2 | On Continuous Learning | Career & Learning |
| 3 | On Solo-preneurship | Tech Meets Business |
| 4 | On Being a Generalist | Career & Learning |
| 5 | On Sales and Tech | Tech Meets Business |
| 6 | On Agile | Software Practices, Teams & Collaboration |
| 7 | On What Makes a Good Team | Teams & Collaboration |
| 8 | On eXtreme Programming | Software Practices |
| 9 | On Customer Support/Experience and Tech | Tech Meets Business |
| 10 | On Tests First | Software Practices |
| 11 | On Tests and RSpec | Software Practices |
| 12 | On Team Efficiency | Teams & Collaboration |
| 13 | On Building a Community | Career & Learning |
| 14 | On Legacy Code | Software Practices |
| 15 | On Software Teaming | Teams & Collaboration |
| 16 | On DDD (Domain-Driven Design) | Software Practices, Technology Deep Dives |
| 17 | On Marketing and Tech | Tech Meets Business |
| 18 | On Starting a New Role | Career & Learning, Teams & Collaboration |
| 19 | On Metrics | Tech Meets Business, Teams & Collaboration |
| 20 | On LLMs | Technology Deep Dives |
| 21 | On PWAs | Technology Deep Dives |
| 22 | On Team Practices | Software Practices, Teams & Collaboration |
| 23 | On Bootcamps | Career & Learning |
| 24 | On Misunderstood Concepts in Tech | Technology Deep Dives |
| 25 | On Taste | Software Practices, Career & Learning |
| 26 | On OOP | Software Practices, Technology Deep Dives |
| 27 | On Ruby (and Rails?) | Technology Deep Dives |

## Seed Data

All 27 episodes seeded via `db/seeds/podcast_episodes.yml` with:
- `title`, `description`, `episode_number`, `published_at`
- `embed_code`: empty
- `external_links`: empty

Categories seeded alongside episodes. The seed script updated to handle `PodcastCategory` creation and episode-category associations.

## UI Changes

Episode cards on the podcast page (`/podcast`) display category labels as small tags/badges. No filtering UI.

## Out of Scope

- Platform-specific listen links (Spotify, Apple Podcasts) — to be added manually via admin later
- Category-based filtering on the podcast page
- RSS feed auto-sync (episodes managed via seeds and admin)
