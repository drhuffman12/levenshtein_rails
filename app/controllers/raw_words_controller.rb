class RawWordsController < ApplicationController
  before_action :set_raw_word, only: [:show, :edit, :update, :destroy]

  # GET /raw_words
  # GET /raw_words.json
  def index
    @raw_words = RawWord.all
  end

  # GET /raw_words/1
  # GET /raw_words/1.json
  def show
  end

  # GET /raw_words/new
  def new
    @raw_word = RawWord.new
  end

  # GET /raw_words/1/edit
  def edit
  end

  # POST /raw_words
  # POST /raw_words.json
  def create
    @raw_word = RawWord.new(raw_word_params)

    respond_to do |format|
      if @raw_word.save
        format.html { redirect_to @raw_word, notice: 'Raw word was successfully created.' }
        format.json { render :show, status: :created, location: @raw_word }
      else
        format.html { render :new }
        format.json { render json: @raw_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raw_words/1
  # PATCH/PUT /raw_words/1.json
  def update
    respond_to do |format|
      if @raw_word.update(raw_word_params)
        format.html { redirect_to @raw_word, notice: 'Raw word was successfully updated.' }
        format.json { render :show, status: :ok, location: @raw_word }
      else
        format.html { render :edit }
        format.json { render json: @raw_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raw_words/1
  # DELETE /raw_words/1.json
  def destroy
    @raw_word.destroy
    respond_to do |format|
      format.html { redirect_to raw_words_url, notice: 'Raw word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_raw_word
      @raw_word = RawWord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def raw_word_params
      params.require(:raw_word).permit(:name, :is_test_case, :word_id)
    end
end
