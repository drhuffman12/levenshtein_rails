class WordFriendsController < ApplicationController
  before_action :set_word_friend, only: [:show, :edit, :update, :destroy]

  # GET /word_friends
  # GET /word_friends.json
  def index
    @word_friends = WordFriend.order(:word_from_id, :word_to_id).all
    # @word_friends = WordFriend.all
  end

  # GET /word_friends/1
  # GET /word_friends/1.json
  def show
  end

  # GET /word_friends/new
  def new
    @word_friend = WordFriend.new
  end

  # GET /word_friends/1/edit
  def edit
  end

  # POST /word_friends
  # POST /word_friends.json
  def create
    @word_friend = WordFriend.new(word_friend_params)

    respond_to do |format|
      if @word_friend.save
        format.html { redirect_to @word_friend, notice: 'Word friend was successfully created.' }
        format.json { render :show, status: :created, location: @word_friend }
      else
        format.html { render :new }
        format.json { render json: @word_friend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /word_friends/1
  # PATCH/PUT /word_friends/1.json
  def update
    respond_to do |format|
      if @word_friend.update(word_friend_params)
        format.html { redirect_to @word_friend, notice: 'Word friend was successfully updated.' }
        format.json { render :show, status: :ok, location: @word_friend }
      else
        format.html { render :edit }
        format.json { render json: @word_friend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /word_friends/1
  # DELETE /word_friends/1.json
  def destroy
    @word_friend.destroy
    respond_to do |format|
      format.html { redirect_to word_friends_url, notice: 'Word friend was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word_friend
      @word_friend = WordFriend.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def word_friend_params
      params.require(:word_friend).permit(:word_from_id, :word_to_id, :traced_by, :traced_last_by)
    end
end
