# Learning Skills Seed Design

## Goal

Replace the placeholder categories in `db/seeds/categories.yml` with real learning journey data, populated via the existing seed script.

## Categories (7 total, ordered by position)

| Position | Name |
|----------|------|
| 1 | Ruby/Rails |
| 2 | Frontend |
| 3 | Engineering Fundamentals |
| 4 | Testing |
| 5 | Continuous Delivery |
| 6 | Pair/Ensemble Programming |
| 7 | Systems Thinking |

## Learning Moments

### 1. Ruby/Rails (14 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| consumed | LeWagon bootcamp | 2018-06-01 | |
| applied | StudyAdvisor project | 2018-09-01 | |
| consumed | The Complete Guide to Rails Performance | 2020-01-01 | |
| experimented | Service Objects | 2020-01-01 | |
| applied | StudyCall project | 2020-06-01 | |
| experimented | Hotwire | 2021-01-01 | |
| consumed | Ruby Under a Microscope | 2022-01-01 | |
| experimented | Minitest | 2022-01-01 | |
| experimented | Lambdas | 2022-01-01 | |
| consumed | Design Patterns in Ruby | 2022-06-01 | |
| applied | Yago project | 2022-09-01 | |
| applied | Recovr project | 2023-01-01 | |
| consumed | Layered Design for Ruby on Rails Applications | 2024-01-01 | |
| experimented | RSpec | 2019-01-01 | |

### 2. Frontend (5 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| applied | StudyAdvisor (Vue) | 2018-09-01 | |
| applied | StudyCall (Hotwire) | 2020-06-01 | |
| experimented | Reactive Programming | 2022-01-01 | |
| applied | Yago (Vue) | 2022-09-01 | |
| applied | Recovr (React) | 2023-01-01 | |

### 3. Engineering Fundamentals (5 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| consumed | Design Patterns (Gang of Four) | 2019-01-01 | |
| consumed | The Pragmatic Programmer | 2019-06-01 | |
| consumed | Clean Code | 2020-01-01 | |
| consumed | Algorithms in a Nutshell | 2020-06-01 | |
| consumed | eXtreme Programming | 2024-01-01 | |

### 4. Testing (3 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| consumed | TDD by Example | 2022-01-01 | |
| consumed | BDD in Action | 2023-01-01 | |
| consumed | ZOMBIE testing | 2023-06-01 | |

### 5. Continuous Delivery (5 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| consumed | The Pragmatic Programmer | 2019-06-01 | |
| applied | TDD practice | 2020-01-01 | |
| applied | Ask, Show, Ship | 2023-01-01 | |
| consumed | eXtreme Programming | 2024-01-01 | |
| consumed | This is Lean | 2025-01-01 | |

### 6. Pair/Ensemble Programming (3 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| consumed | Code with the Power of the Crowd | 2023-01-01 | |
| consumed | So We Tried Ensemble Programming | 2024-06-02 | https://blog.codemanship.dev/so-we-tried-ensemble-programming |
| consumed | Software Teaming | 2025-02-20 | https://blog.codemanship.dev/software-teaming |

### 7. Systems Thinking (7 moments)

| Type | Description | Date | URL |
|------|-------------|------|-----|
| applied | StudyAdvisor - CTO/Team Lead | 2018-09-01 | |
| applied | StudyCall - CTO/Team Lead | 2020-06-01 | |
| consumed | Shape Up | 2021-01-01 | |
| applied | Recovr - Team Lead | 2023-01-01 | |
| consumed | The Scrum Guide | 2025-01-01 | |
| consumed | This is Lean | 2025-01-01 | |
| consumed | Thinking in Systems | 2025-06-01 | |

## Implementation

Single change: replace the contents of `db/seeds/categories.yml` with the data above in the existing YAML format. No code changes needed - the seed runner already handles this format.
