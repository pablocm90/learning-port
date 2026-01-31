# Paint Drip Learning Design

Inspired by Kent Beck's ["Paint Drip People"](https://tidyfirst.substack.com/p/paint-drip-people) concept as an alternative to T-shaped skills.

## Goals

1. **Personal authenticity** - Represent how learning actually happens (organically, not linearly)
2. **Visual storytelling** - Communicate the paint drip metaphor visually

## The Metaphor

- **Brush stroke** = continuous exploration across domains
- **Paint accumulating** = growing interest in certain areas
- **Drips rolling down** = organic deepening into specializations
- **Drip length** = depth of learning (unpredictable which ones go deep)

## Data Model

### Category

The broad domains (the brush stroke positions).

| Field    | Type    | Description                          |
|----------|---------|--------------------------------------|
| name     | string  | e.g., "Agile", "Collaborative Coding"|
| position | integer | Order along the brush stroke (L→R)   |

### LearningMoment

The individual learning experiences (the droplets that form drips).

| Field           | Type     | Description                              |
|-----------------|----------|------------------------------------------|
| category_id     | FK       | Belongs to a category                    |
| engagement_type | enum     | consumed, experimented, applied, shared  |
| description     | string   | Short text, e.g., "Kent Beck's XP book"  |
| url             | string   | Optional link to resource                |
| occurred_at     | date     | When this learning happened              |

### Engagement Types

| Type         | Weight | Meaning                    |
|--------------|--------|----------------------------|
| consumed     | 1      | Passive (read, watched)    |
| experimented | 2      | First attempt              |
| applied      | 3      | Real use                   |
| shared       | 4      | Taught others              |

### Calculated Properties (not stored)

- **Drip length** = weighted sum of moments + time-span bonus (first moment to latest)
- **Engagement icons** = which types are present in this category

## Visual Design

### The Canvas

- Full-width section
- Subtle texture or off-white background evoking canvas/watercolor paper

### The Brush Stroke (top)

- Horizontal band across the top
- Slightly irregular/organic edge (not a perfect rectangle)
- Category names positioned along it, spaced evenly
- Feels like one continuous stroke drawn across domains

### The Drips (hanging down)

- Each category has a drip extending downward from the brush stroke
- Drip length varies based on weighted engagement + time span
- Gradient: deeper drips are slightly darker/more saturated
- Organic, slightly irregular edges (not perfect rectangles)

### Engagement Icons

- Small icons at the base of each drip
- Four icons: consumed, experimented, applied, shared
- Only shown if that engagement type exists in the category
- Muted/subtle styling

## Interaction

### Expanding a Drip

- **Trigger**: Click on a drip (not hover)
- **Animation**: Drip "opens up" to reveal individual droplets
- **Droplet position**: Chronological - oldest at top (near brush), newest at bottom (drip edge)
- **Droplet display**:
  - Engagement icon
  - Description text
  - Link icon if URL exists (clickable)
- Droplets have same organic/paint aesthetic as the drip

### Collapsing

- Click elsewhere or click drip again to collapse
- Smooth animation back to summary view
- Only one drip expanded at a time

## Page Structure

### Learning Portfolio Page (`/learning`)

- Full paint drip visualization
- Optional brief intro text explaining the concept (or "?" icon for explanation)

### Homepage Section

- Mini version of the brush stroke
- Shows 3-4 most active categories (most recent moments)
- Links to full portfolio page

## Admin Interface

### Managing Categories

- Simple list of categories
- Add/edit/delete
- Drag to reorder (sets position along brush stroke)
- Fields: name only

### Managing Learning Moments

- List view grouped by category (or filterable)
- Add new moment:
  - Select category
  - Pick engagement type (dropdown)
  - Enter description
  - Optional URL
  - Date occurred
- Edit/delete existing moments

### Quick Add

- Streamlined form on main admin page
- Category, type, description, link, date → save → ready for next

## Migration

- Replace existing `LearningItem` model entirely
- Start fresh with new data model
