require 'pry'
require 'base64'
require 'zlib'
# NEED TO FIX UPDATE AND CREATE ROUTES! CURRENTLY DOES NOT WORK WITH API. SOMETHING WEIRD WITH PARAMS NOT BEING COLLECTED

class SpotsController < ApplicationController
  before_action :set_spot, only: [:show, :edit, :update, :destroy, :add_image]
  before_action :authorize, only: [:index, :show, :edit, :create, :update, :destroy, :new]
  before_action :get_spots


  # GET /spots
  # GET /spots.json
  def index
    # Idea: for the list of spots to display: find the 10 closest to your location
  end

  # GET /spots/1
  # GET /spots/1.json
  def show
    reviews_json = HTTParty.get("http://localhost:3000/reviews" )
    @reviews = []
    reviews_json.each do |review|
      if review.fetch("spot_id").to_i === params[:id].to_i
        @reviews.push(review)
        puts 'review pushed'
      end
    end
    if (@spot.img.length > 10)
      img = Zlib::Inflate.inflate(@spot.img)
      binding.pry
      img = Base64.decode64(img)
    end
    @response = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?lat=#{@spot.lat}&lon=#{@spot.lon}&appid=#{Rails.application.credentials.weather_api_key}")
  end

  # GET /spots/new
  def new
    @spot = Spot.new
  end

  # GET /spots/1/edit
  def edit
  end

  # POST /spots
  # POST /spots.json
  def create
    spot2 = Spot.order("created_at").last
    id = (spot2.id.to_i) + 1
    @spot = Spot.new(spot_params)
    @spot.id = id
    respond_to do |format|
      if @spot.save
        HTTParty.post("http://localhost:3000/spots?name=#{spot_params[:name]}&lat=#{spot_params[:lat]}&lon=#{spot_params[:lon]}&description=#{spot_params[:description]}&features=#{spot_params[:features]}&spot_type=#{spot_params[:spot_type]}&img=#{spot_params[:img]}")
        format.html { redirect_to @spot, notice: 'Spot was successfully created.' }
        format.json { render :show, status: :created, location: @spot }
      else
        format.html { render :new }
        format.json { render json: @spot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spots/1
  # PATCH/PUT /spots/1.json
  def update
    respond_to do |format|
      if @spot.update(spot_params)
        if (params[:spot].has_key?(:img))
          path = params[:spot][:img].tempfile.path
          file = File.open(path)
          encoded_img = Base64.encode64(file.read)
          encoded_img = Zlib::Deflate.deflate(encoded_img)
          HTTParty.patch("http://localhost:3000/spots/#{params[:id]}?name=#{spot_params[:name]}&lat=#{spot_params[:lat]}&lon=#{spot_params[:lon]}&description=#{spot_params[:description]}&features=#{spot_params[:features]}&spot_type=#{spot_params[:spot_type]}&img=#{encoded_img}")
        else
          HTTParty.patch("http://localhost:3000/spots/#{params[:id]}?name=#{spot_params[:name]}&lat=#{spot_params[:lat]}&lon=#{spot_params[:lon]}&description=#{spot_params[:description]}&features=#{spot_params[:features]}&spot_type=#{spot_params[:spot_type]}&img=#{spot_params[:img]}")
        end
        format.html { redirect_to @spot, notice: 'Spot was successfully updated.' }
        format.json { render :show, status: :ok, location: @spot }
      else
        format.html { render :edit }
        format.json { render json: @spot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spots/1
  # DELETE /spots/1.json
  def destroy
    HTTParty.delete("http://localhost:3000/spots/#{@spot.id}")
    @spot.destroy
    respond_to do |format|
      format.html { redirect_to spots_url, notice: 'Spot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_spot
    @spot = Spot.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def spot_params
    params.require(:spot).permit(:name, :lat, :lon, :spot_type, :features, :img, :description, :spot_photos)
    # params.require(:spot).permit(:name, :lat, :lon, :spot_type, :features, :img, :description, spot_photos: [])
  end

  def get_spots
    @spots = []
    Spot.destroy_all
    spots_json = HTTParty.get("http://localhost:3000/spots" )
    spots_json.each do |spot|
      spot = Spot.create!({
        :name => spot.fetch('name'),
        :lat => spot.fetch('lat'),
        :lon => spot.fetch('lon'),
        :description => spot.fetch('description'),
        :spot_type => spot.fetch('spot_type'),
        :features => spot.fetch('features'),
        :img => spot.fetch('img'),
        :id => spot.fetch('id'),
        :created_at => spot.fetch('created_at'),
        :updated_at => spot.fetch('updated_at'),
        # calc on front end instead of storing in api's db ??? --v
        # :avg_rating => spot.fetch('avg_rating')
        })
        @spots.push(spot)
      end
    end
  end
