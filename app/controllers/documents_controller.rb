class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    # obj = get_aws_object(@document.key)
    # @url = obj.presigned_url(:get, expires_in: 600)
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new
    @document.save
    object_key =  "uploads/documents/key/#{@document.id}"
    @document.update(key: object_key)
    obj = get_aws_object(object_key)
    obj.upload_file((params[:document][:key]).path)

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    object_key =  @document.key
    obj = get_aws_object(object_key)
    obj.upload_file((params[:document][:key]).path)

    respond_to do |format|
      if @document.update(key: object_key)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def fetch_object
    @document = Document.find(params[:document_id])
    obj = get_aws_object(@document.key)
    @url = obj.presigned_url(:get, expires_in: 600)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:key)
    end

    def get_aws_object(object_key)
      s3 = Aws::S3::Resource.new({region:ENV['AWS_REGION'],
                                  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_ID'], ENV['AWS_SECRET_KEY'])})
      obj = s3.bucket('apayi.documents.bucket').object(object_key)
    end
end
