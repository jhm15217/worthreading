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
      @emails = Email.where("'emails'.'from' = ? OR 'emails'.'to' = ?", current_user.email, current_user.email).paginate(page: params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /emails/1
  # NOTE Need to fix up user access 
  # NOTE Need to insert worth-reading button at the bottom of last part
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
    if (from = email_address_parts(params['from'])) and (@user = find_or_register(from[:email]))  
      @email = @user.emails.create!(
        from: from[:email],
        to: params['Delivered-To'], 
        subject: params['subject'],
        body: params['body-html']
      )
      render text: "Email Received" 
      if receiver = @email.to.match(/(.*)\+(.*)@/) #It's an individual email address
        if receiver = find_or_register(receiver.captures[0] + '@' + receiver.captures[1])
         send_msg_to_individual( @user, receiver, @email) 
        else
          UserMailer.error_email("Bad individual recipient: #{@email.to.match(/(.*)@/).captures[0].sub(/[+]/,"@")}",
                                 @user, @email).deliver
        end
      elsif @email.to == "subscribers@worth-reading.org"
        if @user.subscribers.empty?
          error = "There are no subscribers on your list. Please add subscribers to your list"
          UserMailer.error_email(error, @user, @email).deliver

          #UserMailer.delay.send_error(error, @user, @email)
        else
          @user.subscribers.each do |subscriber|
            send_msg_to_individual(@user, subscriber, @email)
          end
          
          # @user.delay.send_msg_to_subscribers(@email, {|log_entry| UserMailer.send})

        end
      elsif @email.to == 'notifications@worth-reading.org'  # log this
        #don't bounce this
      else
        UserMailer.error_email("Bad email recipient: #{@email.to}", @user, @email).deliver
        puts Time.now.to_s + ": Bad email recipient: #{@email.to}"
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

    @wr_logs = @email.wr_logs.paginate(page: params[:page])
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
end
