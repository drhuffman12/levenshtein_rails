class WordLengthsController < ApplicationController
  before_action :set_word_length, only: [:show, :edit, :update, :destroy]

  # GET /word_lengths
  # GET /word_lengths.json
  def index
    @word_lengths = WordLength.order(:length).all
  end

  # GET /word_lengths/1
  # GET /word_lengths/1.json
  def show
  end

  # GET /word_lengths/new
  def new
    @word_length = WordLength.new
  end

  # GET /word_lengths/1/edit
  def edit
  end

  # POST /word_lengths
  # POST /word_lengths.json
  def create
    @word_length = WordLength.new(word_length_params)

    respond_to do |format|
      if @word_length.save
        format.html { redirect_to @word_length, notice: 'Word length was successfully created.' }
        format.json { render :show, status: :created, location: @word_length }
      else
        format.html { render :new }
        format.json { render json: @word_length.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /word_lengths/1
  # PATCH/PUT /word_lengths/1.json
  def update
    respond_to do |format|
      if @word_length.update(word_length_params)
        format.html { redirect_to @word_length, notice: 'Word length was successfully updated.' }
        format.json { render :show, status: :ok, location: @word_length }
      else
        format.html { render :edit }
        format.json { render json: @word_length.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /word_lengths/1
  # DELETE /word_lengths/1.json
  def destroy
    @word_length.destroy
    respond_to do |format|
      format.html { redirect_to word_lengths_url, notice: 'Word length was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word_length
      @word_length = WordLength.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def word_length_params
      params.require(:word_length).permit(:length)
    end
end
