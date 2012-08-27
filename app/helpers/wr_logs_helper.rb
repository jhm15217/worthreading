module WrLogsHelper

def best_recent_emails
  t = WrLog.select('email_id, sender_id, count(worth_reading) as liked').group('email_id, sender_id').uniq
  .sort!{|t1,t2| Email.find(t2.email_id).created_at <=> Email.find(t1.email_id).created_at }.take(500).sort!{|t1,t2|t2.liked <=> t1.liked}.take(10)
 end

end
