class EmailsController < ApplicationController
  
  include UsersHelper

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
      if @user = find_or_register(params['sender'])
        @email = @user.emails.new(
          from: params['sender'], 
          to: params['recipient'], 
          subject: params['subject'],
          body: params['body-plain']
        )
        @email.save ? (render text: "Email Received") : ()
        wr_log_entry = WrLog.new(action:"email", sender_id:find_or_register(@email.from),
                                 receiver_id:find_or_register(@email.to), email_id:@email.id, responded: false)
        wr_log_entry.save
    else
      redirect_to root_path  ## params['sender'] is bad 
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
