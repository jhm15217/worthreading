class EmailsController < ApplicationController
  before_filter :signed_in_user, except: [:create, :show]
  before_filter :correct_user, only: [:emails_sent_to_subscriber]

  # This is used to disable Rails request forger protection for this controller
  # since we are receiving post data from mailgun
  skip_before_filter :verify_authenticity_token, only: [:create]

  # GET /emails
  def index
    # TODO Need to ensure only correct user access or may need to rethink this
    if signed_in? && current_user.admin?
      @emails = Email.paginate(page: params[:page])
    else
      @emails = Email.where("'emails'.'from' = ? OR 'emails'.'to' = ?", current_user.email, current_user.email).
          paginate(page: params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /emails/1
  # NOTE Need to fix up user access 
  # NOTE Need to insert forward button at the bottom of last part
  def show
    @email = Email.find(params[:id])
    if params[:more] == "1" 
      log = WrLog.find(params[:wr_log])

      if log.token_identifier == params[:token_identifier]
        log.action = "more"
        log.email_part = 2
        log.save
      end

      @parts = @email.body.split(/&lt;more&gt;|<more>/m)
      # @parts.paginate(page: params[:page], per_page: 1)
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Used to capture emails from Mailgun.
  # Mailgun is directed through its routes configuration to send emails towards
  # heroku app at app_name.herokuapp.com/emails
  # POST /emails
  def create
    if from = email_address_parts(params['from']) and @user = Email.find_or_register(from[:email])
      render text: "Email Received"
      to_list = email_address_list(params['Delivered-To']).collect do |address|
        if m = address[:email].match(/(.*)\+(.*)@/) #It's an individual email address
          m.captures[0] + '@' + m.captures[1]
        else
          address[:email]
        end
      end.join(', ')
      @email = @user.emails.new(
        from: @user.email,
        to: to_list,
        subject: params['subject'],
        body: params['body-html'],
        parts: params['body-html'].split(/&lt;more&gt;|<more>/)
      )
      if @email.save
        @email.deliver_all(@email.process(@user))
      else
        puts "Bad email: " + @email.inspect
      end
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

  # GET /compose_new
  # opens compose email window
  def compose_new
    render 'chrome_extension/new'
  end

  # Brings up a page of the emails sent to a particular subscriber by a sender
  # GET 
  def emails_sent_to_subscriber
    @receiver = User.find(params[:receiver_id])
    @wr_logs =  WrLog.where("sender_id = ? and receiver_id = ?", @user, @receiver).
      order("created_at DESC").
      paginate(page: params[:page])
  end

  # Brings up a page of the recipients of a particular email
  # GET
  def recipient_list
    @email = Email.find(params[:id])
    redirect_to root_path unless current_user?(@email.user) # Restrict to only current user

    @wr_logs = @email.wr_logs.select{|w| w.opened || w.email_part > 0 || w.followed_url || w.forwarded}.paginate(page: params[:page], per_page: 25)
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
end
