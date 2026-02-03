require 'rails_helper'

RSpec.describe PodcastEpisodesHelper, type: :helper do
  describe "#podcast_category_meta" do
    it "returns metadata for a known slug" do
      meta = helper.podcast_category_meta("software-practices")

      expect(meta[:description]).to be_present
      expect(meta[:icon]).to be_present
      expect(meta[:color]).to eq("#F97316")
    end

    it "returns metadata for every known category" do
      %w[software-practices teams-and-collaboration career-and-learning
         tech-meets-business technology-deep-dives all].each do |slug|
        meta = helper.podcast_category_meta(slug)
        expect(meta[:description]).to be_present, "Missing description for #{slug}"
        expect(meta[:icon]).to be_present, "Missing icon for #{slug}"
        expect(meta[:color]).to match(/\A#[0-9A-Fa-f]{6}\z/), "Invalid color for #{slug}"
      end
    end

    it "returns a fallback for an unknown slug" do
      meta = helper.podcast_category_meta("unknown-category")

      expect(meta[:description]).to eq("")
      expect(meta[:icon]).to be_present
      expect(meta[:color]).to eq("#fe5f00")
    end
  end
end
