class WrLogsController < ApplicationController
  before_filter :admin_user, only: [:by_email, :by_sender, :by_receiver ]

  # Constants
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'
  # GET /wr_logs
  # GET /wr_logs.json
  def index
    @wr_logs = WrLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wr_logs }
    end
  end

  # GET /wr_logs/1
  # GET /wr_logs/1.json
  # Response page for clicking on the worth reading button
  def show
    @wr_log = WrLog.find(params[:id])
    @email = Email.find(@wr_log.email_id)
    @receiver = User.find_by_id(@wr_log.receiver_id) 
    @sender = User.find_by_id(@wr_log.sender_id)
    
    if params[:token_identifier] != @wr_log.token_identifier
      redirect_to root_path, 
        flash: { error: "I'm sorry you are not allowed to access that page"}
      end

    if params[:worth_reading] && !@wr_log.worth_reading 
      @wr_log.action = "worth reading"
      @wr_log.worth_reading = Time.now
      @wr_log.save
      if @sender.email_notify?
        UserMailer.alert_change_in_wr_log(@wr_log).deliver
      end
      if @receiver.forward?
        @receiver.subscribers.each do |subscriber|
          UserMailer.send_msg(@receiver, subscriber, @email).deliver
        end
      end
      render :nothing
    elsif params[:more]
      @wr_log.action = "more"
      @wr_log.email_part = params[:more].to_i + 1
      @wr_log.worth_reading = Time.now
      @wr_log.save
      @message = @wr_log.abstract_message
      respond_to do |format|
        format.html # show.html.haml
        format.json { render json: @wr_log }
      end
    else
      redirect_to root_path, flash: { error: "Unknown request" }
    end
  end

  # GET /wr_logs/new
  # GET /wr_logs/new.json
  def new
    @wr_log = WrLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wr_log }
    end
  end

  # GET /wr_logs/1/edit
  def edit
    @wr_log = WrLog.find(params[:id])
  end

  # POST /wr_logs
  # POST /wr_logs.json
  def create
    @wr_log = WrLog.new(params[:wr_log])

    respond_to do |format|
      if @wr_log.save
        format.html { redirect_to @wr_log, notice: 'Wr log was successfully created.' }
        format.json { render json: @wr_log, status: :created, location: @wr_log }
      else
        format.html { render action: "new" }
        format.json { render json: @wr_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wr_logs/1
  # PUT /wr_logs/1.json
  def update
    @wr_log = WrLog.find(params[:id])

    respond_to do |format|
      if @wr_log.update_attributes(params[:wr_log])
        format.html { redirect_to @wr_log, notice: 'Wr log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wr_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wr_logs/1
  # DELETE /wr_logs/1.json
  def destroy
    @wr_log = WrLog.find(params[:id])
    @wr_log.destroy

    respond_to do |format|
      format.html { redirect_to wr_logs_url }
      format.json { head :no_content }
    end
  end

  # GET /wr_logs/1/msg_opened/:token_identifier
  def msg_opened
    @wr_log = WrLog.find(params[:id])
    token_identifier = params[:token_identifier]

    if @wr_log.action == "email" && @wr_log.token_identifier == token_identifier
      @wr_log.action = "opened"
      @wr_log.opened = Time.now
      @wr_log.save
      @wr_log.reload
      if User.find(@wr_log.sender_id).email_notify?
        UserMailer.alert_change_in_wr_log(@wr_log).deliver
      end
    end

    send_file Rails.root.join("public", "images", "beacon.gif"), type: "image/gif", disposition: "inline"
  end


  #GET /by_email
  def by_email
  end

  #GET /by_sender
  def by_sender
    lines = WrLog.select('sender_id, count(sender_id) as sender_count,
                     count(opened) as opened_count, count(worth_reading) as
                     liked_count').group('sender_id')
    @percents = Array.new(lines.length){|i| { name: User.find(lines[i][:sender_id]).name,
                                             sender_count: lines[i][:sender_count],
                                             opened_percent: 100.0*(lines[i][:opened_count].to_f)/lines[i][:sender_count].to_f,
                                             liked_percent: 100.0*(lines[i][:liked_count].to_f)/lines[i][:sender_count].to_f } }
    @percents.sort!{|x,y| -(x[:liked_percent] <=> y[:liked_percent])}    
  end

  #GET /by_receiver
  def by_receiver
    lines = WrLog.select('receiver_id, count(receiver_id) as receiver_count,
                     count(opened) as opened_count, count(worth_reading) as
                     liked_count').group('receiver_id')
    @percents = Array.new(lines.length){|i| { name: User.find(lines[i][:receiver_id]).name,
                                             receiver_count: lines[i][:receiver_count],
                                             opened_percent: 100.0*(lines[i][:opened_count].to_f)/lines[i][:receiver_count].to_f,
                                             liked_percent: 100.0*(lines[i][:liked_count].to_f)/lines[i][:receiver_count].to_f } }
    @percents.sort!{|x,y| -(x[:liked_percent] <=> y[:liked_percent])}    
  end

  private

  def admin_user
    redirect_to(root_path) unless signed_in? && current_user.admin? 
  end
end
