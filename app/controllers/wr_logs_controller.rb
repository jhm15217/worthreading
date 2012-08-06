class WrLogsController < ApplicationController
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
  def show
    @wr_log = WrLog.find(params[:id])
    @email = Email.find(@wr_log.email_id)
    @receiver = User.find_by_id(@wr_log.receiver_id) 
    @sender = User.find_by_id(@wr_log.sender_id)

    if params[:action] && @wr_log.action != "worth reading" 
      @wr_log.action = "worth reading"
      @wr_log.worth_reading = Time.now
      @wr_log.save
      UserMailer.alert_change_in_wr_log(@wr_log).deliver

      # UserMailer.delay.alert_change_in_wr_log(@wr_log)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wr_log }
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
    puts "WrLog[#{@wr_log.id}]: Action before save '#{@wr_log.action}'"

    if @wr_log.action == "email" && @wr_log.token_identifier == token_identifier
      @wr_log.action = "opened"
      @wr_log.opened = Time.now
      @wr_log.save
      @wr_log.reload
      UserMailer.alert_change_in_wr_log(@wr_log).deliver
      puts "WrLog[#{@wr_log.id}]: Action after save '#{@wr_log.action}'"
    end

    send_file Rails.root.join("public", "images", "beacon.gif"), type: "image/gif", disposition: "inline"
  end
  

  #GET /by_email
  def by_email
    redirect_to(root_path) unless signed_in? 
  end

  #GET /by_sender
  def by_sender
    redirect_to(root_path) unless signed_in? 
  end

  #GET /by_receiver
  def by_receiver
    redirect_to(root_path) unless signed_in?
  end
end
