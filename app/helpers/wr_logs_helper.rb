module WrLogsHelper

  def best_recent_emails
    t = WrLog.select('email_id, count(forwarded) as forwarded').group('email_id').uniq
    puts t.inspect
    t = t.sort!{|t1,t2| Email.find(t2.email_id).created_at <=> Email.find(t1.email_id).created_at }.take(500)
    puts t.inspect
    t = t.sort!{|t1,t2|t2.forwarded <=> t1.forwarded}.take(10)
    puts t.inspect
    t
  end

end
