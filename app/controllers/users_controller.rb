class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  has_attached_file :attach_file,
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/aws.yml",
  :path => ":class/:attachment/:id/:style/:filename",
  :path => "klaseko-gcc-pdfs/:filename",
  :url => "s3_domain_url"

  def copy_and_delete(paperclip_file_path, raw_source)
    s3 = AWS::S3.new # create new S3 object
    destination = s3.buckets['klaseko-gcc-pdfs'].objects[paperclip_file_path]
    sub_source =CGI.unescape(raw_source)
    sub_source.slice(0)! # Removing the extra "/" of the file_path from the beggining
    source = s3.buckets['klaseko-gcc-pdfs'].objects["#{sub_source}"]
    source.copy_to(destination) # method from aws_gem
    source.delete # delete the tempfile
  end

  def
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
      @user = User.find(params[:id])
      respond_to do |format|
        format.html
        format.pdf do

          pdf = Prawn::Document.new
          # First Approach
          #pdf.text "Sample Test PDF`s"
          #send_data pdf.render, filename: "klaseko_gift_certificate_#{@user.id}.pdf",
          #                      type: "application/pdf",
          #                     disposition: "inline"

          # Second Another approach
          pdf.text('GCC plss')
          pdf.render_file('prawn.pdf')
          pdf_file = File.open('prawn.pdf')

          

          # pdff = Pdf.new()
          # pdff.pdff_file = pdf_file
          # pdff.id = user.id
          # pdff.save
        end
      end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email)
    end
end
