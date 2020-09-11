module Search
  # This does not follow the same pattern as our other classes bc it is
  # using the FeedContent index to search for ReadingList reaction articles
  class ReadingList
    def self.search_documents(params:, user:)
      new(params: params, user: user).parsed_reading_list
    end

    def initialize(params:, user:)
      self.status = params.delete(:status)
      self.view_page = params.delete(:page)
      self.view_per_page = params.delete(:per_page)
      self.user = user
      self.search_params = params
    end

    def parsed_reading_list
      ordered_articles = parse_and_order_articles(article_docs)
      [paginate_articles(ordered_articles), total]
    end

    private

    attr_accessor :search_params, :user, :status, :view_page, :view_per_page, :total

    def paginate_articles(ordered_articles)
      start = view_per_page * view_page
      ordered_articles[start, view_per_page] || []
    end

    def article_docs
      return @article_docs if @article_docs

      # Gather articles from Elasticsearch based on search criteria containing
      # tags, text search, status, and the list of IDs of all articles in a user's
      # readinglist
      docs = FeedContent.search_documents(
        params: search_params.merge(
          id: search_ids,
          class_name: "Article",
          page: 0,
          per_page: reading_list_article_ids.count,
        ),
      )
      self.total = docs.count
      @article_docs = docs.index_by { |doc| doc["id"] }
    end

    def reading_list_article_ids
      # Collect all reading list IDs and article IDs for a user
      @reading_list_article_ids ||= user.reactions.readinglist.where(status: status).pluck(:reactable_id, :id).to_h
    end

    def search_ids
      reading_list_article_ids.keys.map { |id| "article_#{id}" }
    end

    def parse_and_order_articles(articles)
      # Create hashes that contain the fields our view needs on the frontend
      reading_list_article_ids.map do |article_id, reaction_id|
        found_article_doc = articles[article_id]
        next unless found_article_doc

        { id: reaction_id, user_id: user.id, reactable: articles[article_id] }
      end.compact
    end
  end
end
