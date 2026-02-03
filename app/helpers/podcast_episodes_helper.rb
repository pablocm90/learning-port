module PodcastEpisodesHelper
  CATEGORY_META = {
    "software-practices" => {
      description: "Coding patterns, architecture, and development workflows.",
      icon: "🛠️",
      color: "#F97316"
    },
    "teams-and-collaboration" => {
      description: "How teams communicate, align, and ship together.",
      icon: "🤝",
      color: "#22C55E"
    },
    "career-and-learning" => {
      description: "Growth, mentorship, and navigating a dev career.",
      icon: "🌱",
      color: "#3B82F6"
    },
    "tech-meets-business" => {
      description: "Where engineering decisions meet product and strategy.",
      icon: "📈",
      color: "#8B5CF6"
    },
    "technology-deep-dives" => {
      description: "Going deep on tools, frameworks, and technical concepts.",
      icon: "🧪",
      color: "#E85D75"
    },
    "all" => {
      description: "Every episode, all in one place.",
      icon: "🎧",
      color: "#fe5f00"
    }
  }.freeze

  def podcast_category_meta(slug)
    CATEGORY_META.fetch(slug, { description: "", icon: "🎤", color: "#fe5f00" })
  end
end
