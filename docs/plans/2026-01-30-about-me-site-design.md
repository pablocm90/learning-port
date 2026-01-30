# About Me Site - Full Rewrite Design

## Overview

A personal portfolio and knowledge tracking site rebuilt from scratch with modern Rails.

## Tech Stack

- **Ruby 3.3** (latest stable)
- **Rails 8** (latest)
- **Hotwire** (Turbo + Stimulus) for interactivity
- **SQLite** for database (Rails 8 default, simple for personal site)
- **Tailwind CSS 4** for styling
- **Propshaft** (Rails 8 default asset pipeline)
- **Devise** for admin authentication

## Data Models

### Writer (Admin)

Single admin user for managing content.

| Field | Type | Notes |
|-------|------|-------|
| email | string | Devise |
| encrypted_password | string | Devise |
| name | string | Display name |
| bio | text | About section content |

### LearningItem

Tracks skills and knowledge areas.

| Field | Type | Notes |
|-------|------|-------|
| name | string | e.g., "Ruby", "Kubernetes" |
| icon | string | Emoji or Font Awesome class |
| category | string | e.g., "Languages", "Frameworks", "DevOps" |
| status | enum | learning, practicing, comfortable, expert |
| description | text | Short summary of experience |
| started_at | date | When learning began |
| resources | jsonb | Array of {title, url} |
| notes | text | Personal notes, markdown supported |
| projects | jsonb | Array of {name, url} |
| position | integer | For ordering |
| source | string | "yaml" or "admin" (for seed management) |

### PodcastEpisode

Podcast episodes with embedded players.

| Field | Type | Notes |
|-------|------|-------|
| title | string | Episode title |
| description | text | Episode description |
| episode_number | integer | Episode number |
| published_at | date | Publication date |
| embed_code | text | Raw HTML from Spotify/Anchor/etc. |
| external_links | jsonb | {spotify_url, apple_url, youtube_url} |

## Pages & Navigation

### Main Navigation (Header)

- Logo/Name (links to home)
- Learning Portfolio
- Podcast
- Blog (external link to blog subdomain)

### Home Page

- Hero section: name, title, short bio
- "Currently learning" highlight (pulls from LearningItems)
- Latest podcast episode with embedded player + "See all episodes" link
- Latest blog post (fetched from RSS feed) with title, excerpt, date + "Read more" link

### Learning Portfolio Page

- Grid/list of learning items grouped by category
- Filter by category or status
- Click to expand details (Turbo Frame for smooth expand/collapse)
- Shows resources, notes, related projects when expanded

### Podcast Page

- Episode list with embedded players, newest first
- Each episode: title, description, date, embedded player
- External platform links below each episode

### Admin Dashboard (Authenticated)

- Manage learning items (CRUD)
- Manage podcast episodes (CRUD)
- Edit profile/bio

### Footer

- Contact email
- Social links (GitHub, LinkedIn, Twitter/X, etc.)
- Copyright

## Visual Design

### Color Palette (Dark Mode)

| Purpose | Color | Hex |
|---------|-------|-----|
| Background | Deep slate | #0f172a |
| Surface/cards | Light slate | #1e293b |
| Primary accent | Electric blue | #3b82f6 |
| Secondary accent | Emerald | #10b981 |
| Text | Off-white | #f1f5f9 |
| Muted text | Slate gray | #94a3b8 |

### Typography

- **Headings**: Inter or Geist (clean, modern sans-serif)
- **Body**: Same family, lighter weight
- **Code/technical**: JetBrains Mono or Fira Code

### Style Notes

- Minimal design with generous whitespace
- Subtle borders and shadows on cards
- Smooth hover transitions
- Icons: Lucide or Heroicons
- Mobile-first responsive design

## YAML Seeding

Learning items and podcast episodes can be managed via YAML files for bulk operations.

### Location

- `db/seeds/learning_items.yml`
- `db/seeds/podcast_episodes.yml`

### Example Learning Item YAML

```yaml
- name: Ruby
  icon: "💎"
  category: Languages
  status: comfortable
  description: Primary language for backend development
  started_at: 2018-01-01
  resources:
    - title: Ruby docs
      url: https://ruby-doc.org
  projects:
    - name: This site
      url: https://github.com/pablocm90/learning-port
```

### Seed Behavior

- `source` field tracks origin ("yaml" vs "admin")
- Seeds create new items or update existing yaml-sourced items
- Admin-created items are not overwritten by seeds

## RSS Integration

- Background job fetches latest blog post from RSS feed
- Cached to keep home page fast
- Displays title, excerpt, date with link to full post

## Migration Path

1. Create fresh Rails 8 app with Hotwire
2. Set up Tailwind CSS 4
3. Create models and migrations
4. Build admin authentication with Devise
5. Build static pages (home, about)
6. Build learning portfolio with Turbo
7. Build podcast page with embeds
8. Add RSS feed integration
9. Build admin dashboard
10. Style and polish
11. Deploy
