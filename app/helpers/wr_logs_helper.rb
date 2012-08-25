module WrLogsHelper

def best_recent_emails
  WrLog.limit(1000).select('email_id, sender_id, count(worth_reading) as liked')
           .group('email_id, sender_id').sort!{|t1,t2|-(t1.liked <=> t2.liked)}.take(10)
 end

end
