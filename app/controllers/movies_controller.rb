class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.all_ratings
    # convert all_ratings arr into a hash
    if(@all_ratings_map==nil)
      @all_ratings_map = Hash.new
      @all_ratings.each do |rating|
        @all_ratings_map[rating]=1
      end
    end
    # set the session variable ratings only when we dont uncheck all the ratings
    # if this method is called for the first time, set the sessions variable
    if params[:ratings]!=nil
	session[:ratings]=params[:ratings]
    elsif session[:ratings]==nil
	session[:ratings]=@all_ratings_map
    end
    # if uri request has a value for sort, store it in session.
    if params[:sort].present?
      session[:sort]=params[:sort]
    end
    # if session has stored a value for sort, then order the movies.
    if session[:sort].present?
      @movies = Movie.where(:rating=>session[:ratings].keys).order(session[:sort])
      # set the corresponding variable to hilite =>used in the view to color a heading yellow
      if session[:sort]=='title'
        params[:title_header]= 'hilite'
        params[:release_date_header]= nil
      else
        params[:title_header]= nil
        params[:release_date_header]= 'hilite'
      end
    else
      @movies = Movie.where(:rating=> session[:ratings].keys)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    flash.keep
    # for the uri to show the chosen ratings and sort
    redirect_to movies_path(:sort=>session[:sort],:ratings=>session[:ratings])
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    flash.keep
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    flash.keep
    #redirect_to movies_path
    # for the uri to show the chosen ratings and sort
    redirect_to movies_path(:sort=>session[:sort],:ratings=>session[:ratings])
  end

end
