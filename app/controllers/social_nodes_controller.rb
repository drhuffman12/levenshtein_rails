class SocialNodesController < ApplicationController
  before_action :set_social_node, only: [:show, :edit, :update, :destroy]

  # GET /social_nodes
  # GET /social_nodes.json
  def index
    @social_nodes = SocialNode.order(:word_orig_id, :word_from_id, :word_to_id).all
  end

  # GET /social_nodes/1
  # GET /social_nodes/1.json
  def show
  end

  # GET /social_nodes/new
  def new
    @social_node = SocialNode.new
  end

  # GET /social_nodes/1/edit
  def edit
  end

  # POST /social_nodes
  # POST /social_nodes.json
  def create
    @social_node = SocialNode.new(social_node_params)

    respond_to do |format|
      if @social_node.save
        format.html { redirect_to @social_node, notice: 'Social node was successfully created.' }
        format.json { render :show, status: :created, location: @social_node }
      else
        format.html { render :new }
        format.json { render json: @social_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /social_nodes/1
  # PATCH/PUT /social_nodes/1.json
  def update
    respond_to do |format|
      if @social_node.update(social_node_params)
        format.html { redirect_to @social_node, notice: 'Social node was successfully updated.' }
        format.json { render :show, status: :ok, location: @social_node }
      else
        format.html { render :edit }
        format.json { render json: @social_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /social_nodes/1
  # DELETE /social_nodes/1.json
  def destroy
    @social_node.destroy
    respond_to do |format|
      format.html { redirect_to social_nodes_url, notice: 'Social node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_social_node
      @social_node = SocialNode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def social_node_params
      params.require(:social_node).permit(:word_orig_id, :word_from_id, :word_to_id, :qty_steps)
    end
end
