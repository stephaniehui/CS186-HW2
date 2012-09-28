class AppQuery

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  attr_accessor :posts
  attr_accessor :users
  attr_accessor :user
  attr_accessor :locations
  attr_accessor :following_locations
  attr_accessor :location

  ###########################################
  #  TODO: Implement the following methods  #
  ###########################################

  # Purpose: Show all the locations being followed by the current user
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @following_locations - An array of hashes of location information.
  #                          Order does not matter.
  #                          Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_following_locations(user_id)
    @following_locations = Following.find_by_sql("SELECT * FROM following f, locations l WHERE f.follower_id = ?", user_id)
  end

  # Purpose: Show the information and all posts for a given location
  # Input:
  #   location_id - The id of the location for which to show the information and posts
  # Assign: assign the following variables
  #   @location - A hash of the given location. The hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #   @posts - An array of hashes of post information, for the given location.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_posts_for_location(location_id)
    @location = Locations.find(location_id)
    location_hash = @location.to_hash
    @posts = []
    Posts.find_by_sql("SELECT * FROM posts p WHERE p.location_id = ?", location_id).each do |post|
      @posts << {:author_id => post.author_id, :author => post.author, :text => post.text, :created_at => post.created_at, :location => location_hash}
    end
    @posts = @posts.sort_by{|p| p.created_at}.reverse

  end

  # Purpose: Show the current user's stream of posts from all the locations the user follows
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information from all locations the current user follows.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_stream_for_user(user_id)
    @posts = []
    # Following.find_by_sql("SELECT f.location_id FROM following f WHERE author_id = ?", user_id).each do |l_id|
    Following.find_by_sql("SELECT f.location_id FROM following f WHERE follower_id = ?", user_id).each do |l_id|
      Post.find_all_by_location_id(l_id).each do |post|
        @posts << {:author_id => post.author_id, :author => post.author, :text => post.text, :created_at => post.created_at, :location => Location.find_by_location_id(l_id).to_hash}
      # Locations.find_all_by_id(l_id).each do |loc|
      #   Post.find_all_by_location_id(l)
      # # location_hash = Locations.find(:id => l_id).to_hash
      # Posts.find_by_sql("SELECT * FROM posts p WHERE p.author_id = ?", user_id).each do |post|
      #   @posts << {:author_id => post.author_id, :author => post.author, :text => post.text, :created_at => post.created_at, :location => location_hash}
      end
    end
    @posts = @posts.sort_by{|p| p.created_at}.reverse
    
  end

  # Purpose: Retrieve the locations within a GPS bounding box
  # Input:
  #   nelat - latitude of the north-east corner of the bounding box
  #   nelng - longitude of the north-east corner of the bounding box
  #   swlat - latitude of the south-west corner of the bounding box
  #   swlng - longitude of the south-west corner of the bounding box
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information, which lie within the bounding box specified by the input.
  #                In increasing latitude order.
  #                At most 50 locations.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     * :follows - true if the current user follows this location. false otherwise.
  # Output: None
  def get_nearby_locations(nelat, nelng, swlat, swlng, user_id)
    @locations = []
    all_locations = Locations.all
    all_locations = all_locations.sort_by {|x| x.latitude}
    all_locations.each do |loc|
      if loc.latitude <= nelat && loc.latitude >= swlat && loc.longitude <= nelng && loc.longitude >= swlng
        if Following.find_by_follower_id_and_location_id(user_id, loc.id)
          @locations << {:id => loc.id, :name => loc.name, :latitude => loc.latitude, :longitude => loc.longitude, :follows => true }
        else
          @locations << {:id => loc.id, :name => loc.name, :latitude => loc.latitude, :longitude => loc.longitude, :follows => false }
        end
      end
    end
    # locations_following = Following.find_by_sql("SELECT f.location_id FROM following f WHERE f.follower_id = ?", user_id)
    # locations_not_following = Locations.find_by_sql("SELECT l.location_id FROM locations l")
    # while @locations.length <= 50
    #   locations_following.each do |l1|
    #   locations_following.each do |l_id|
    #     l = Locations.find(:id => l_id)
    #     if l1.latitude <= nelat and l1.latitude >= swlat and l1.longitude <= nelng and l1.longitude >= swlng
    #       @locations << {:id => l1.id, :name => l1.name, :latitude => l1.latitude, :longitude => l1.longitude, :follows => true}
    #     end
    #   end
    #   locations_not_following.each do |l2_id|
    #     l2 = Locations.find(:id => l2_id)
    #     if l2.latitude <= nelat and l2.latitude >= swlat and l2.longitude <= nelng and l2.longitude >= swlng
    #       @locations << {:id => l.id, :name => l.name, :latitude => l.latitude, :longitude => l.longitude, :follows => false}
    #     end
    #   end
    # end
  end

  # Purpose: Create a new location
  # Input:
  #   location_hash - A hash of the new location information.
  #                   The hash MAY include:
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_location(location_hash={})
    if location_hash.empty?
      return false
    end
    if location_hash{:name} == nil 
      return false
    end
    if location_hash{:latitude} == nil
      return false
    end
    if location_hash{:longitude} == nil
      return false
    end
    @location = Locations.new(location_hash)
    if @location.save
      return true
    else
      return false
    end
  end

  # Purpose: The current user follows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should follow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def follow_location(user_id, location_id)
    @following = Following.create(:follower_id => user_id, :location_id => location_id)
  end

  # Purpose: The current user unfollows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should unfollow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def unfollow_location(user_id, location_id)
    Following.find_by_sql("SELECT * FROM following f WHERE f.follower_id = ? AND f.location_id = ?", user_id, location_id).destroy
  end

  # Purpose: The current user creates a post to a given location
  # Input:
  #   user_id - the user id of the current user
  #   post_hash - A hash of the new post information.
  #               The hash may include:
  #     * :location_id - the id of the location
  #     * :text - the text of the posts
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_post(user_id, post_hash={})
    if Users.find(:id => user_id).empty?
      return false
    end
    if post_hash[:location_id] == nil
      return false
    end
    if post_hash[:text] == nil
      return false
    end
    username = Users.find_by_sql("SELECT u.name FROM users u WHERE u.id = ?", user_id).username
    ptext = post_hash[:text]
    plocation = post_hash[:location_id]
    @posts = Posts.create(:author_id => user_id, :author_name => username, :text => ptext, :location_id => plocation)
    return true
  end

  # Purpose: Create a new user
  # Input:
  #   user_hash - A hash of the new post information.
  #               The hash may include:
  #     * :name - name of the new user
  #     * :email - email of the new user
  #     * :password - password of the new user
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: assign the following variables
  #   @user - the new user object
  # Output: true if the creation is successful, false otherwise
  # NOTE: This method is already implemented, but you are allowed to modify it if needed.
  def create_user(user_hash={})
    @user = User.new(user_hash)
    if @user.save
      return true
    else
      return false
    end
  end

  # Purpose: Get all the posts
  # Input: None
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_all_posts
    @posts = []
    Posts.all.each do |p|
      @location = Location.find_by_id(p.location_id)
      @posts << {:author_id => p.author_id, :author => p.name, :text => p.text, :created_at => p.created_at, :location => @location}
    end
    # Posts.find_by_sql("SELECT p.location_id FROM posts p").each do |l_id|
    #   Posts.find_by_sql("SELECT * FROM posts p").each do |post|
    #     @posts << {:author_id => post.author_id, :author => post.name, :text => post.text, :created_at => post.created_at, :location => Location.find(:id => l_id).to_hash}
  end

  # Purpose: Get all the users
  # Input: None
  # Assign: assign the following variables
  #   @users - An array of hashes of user information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :id - id of the user
  #     * :name - name of the user
  #     * :email - email of th user
  # Output: None
  def get_all_users
    @users = []
    User.all.each do |user|
      @users << user.to_hash
    end
  end

  # Purpose: Get all the locations
  # Input: None
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information.
  #                Order does not matter.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_all_locations
    @locations = []
    Location.all.each do |loc|
      @locations << loc.to_hash
    end
  end

  # Retrieve the top 5 users who created the most posts.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_posts - number of posts the user has created
  def top_users_posts_sql
    "SELECT '' AS name, 0 AS num_posts FROM users WHERE 1=2"
  end

  # Retrieve the top 5 locations with the most unique posters. Only retrieve locations with at least 2 unique posters.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the location
  #   * num_users - number of unique users who have posted to the location
  def top_locations_unique_users_sql
    "SELECT '' AS name, 0 AS num_users FROM users WHERE 1=2"
  end

  # Retrieve the top 5 users who follow the most locations, where each location has at least 2 posts
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_locations - number of locations (has at least 2 posts) the user follows
  def top_users_locations_sql
    "SELECT '' AS name, 0 AS num_locations FROM users WHERE 1=2"
  end

end
