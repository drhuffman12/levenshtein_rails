class HistFriendsController < ApplicationController
  before_action :set_hist_friend, only: [:show, :edit, :update, :destroy]

  # GET /hist_friends
  # GET /hist_friends.json
  def index
    # @hist_friends = HistFriend.all
    # @hist_friends = HistFriend.order(:hist_from_id, :hist_to_id).all
    @hist_friends = HistFriend.all
  end

  # GET /hist_friends/1
  # GET /hist_friends/1.json
  def show
  end

  # GET /hist_friends/new
  def new
    @hist_friend = HistFriend.new
  end

  # GET /hist_friends/1/edit
  def edit
  end

  # POST /hist_friends
  # POST /hist_friends.json
  def create
    @hist_friend = HistFriend.new(hist_friend_params)

    respond_to do |format|
      if @hist_friend.save
        format.html { redirect_to @hist_friend, notice: 'Hist friend was successfully created.' }
        format.json { render :show, status: :created, location: @hist_friend }
      else
        format.html { render :new }
        format.json { render json: @hist_friend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hist_friends/1
  # PATCH/PUT /hist_friends/1.json
  def update
    respond_to do |format|
      if @hist_friend.update(hist_friend_params)
        format.html { redirect_to @hist_friend, notice: 'Hist friend was successfully updated.' }
        format.json { render :show, status: :ok, location: @hist_friend }
      else
        format.html { render :edit }
        format.json { render json: @hist_friend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hist_friends/1
  # DELETE /hist_friends/1.json
  def destroy
    @hist_friend.destroy
    respond_to do |format|
      format.html { redirect_to hist_friends_url, notice: 'Hist friend was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hist_friend
      @hist_friend = HistFriend.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hist_friend_params
      params.require(:hist_friend).permit(:hist_from_id, :hist_to_id, :traced_by, :traced_last_by)
    end
end
