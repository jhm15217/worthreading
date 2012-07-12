class EmailsController < ApplicationController

  # This is used to disable Rails request forger protection for this controller
  # since we are receiving post data from mailgun
  skip_before_filter :verify_authenticity_token, only: [:create]

  # GET /emails
  def index
    @emails = Email.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /emails/1
  def show
    @email = Email.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Used to capture emails from Mailgun.
  # Mailgun is directed through its routes configuration to send emails towards
  # heroku app at app_name.herokuapp.com/emails
  # POST /emails
  def create
    puts params
    puts params['email']
#    puts params['email']['sender']
    @email = Email.new(
      from: params['sender'], 
      to: params['recipient'], 
      subject: params['subject'],
      body: params['body-plain']
    )
    if @email.save
      render text: "Email Received"
    else 
      redirect_to root_path
    end
  end

  # DELETE /emails/1
  def destroy
    @email = Email.find(params[:id])
    @email.destroy

    respond_to do |format|
      format.html { redirect_to emails_url }
    end
  end
end
