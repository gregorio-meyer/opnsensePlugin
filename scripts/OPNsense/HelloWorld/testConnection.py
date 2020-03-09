import os
import socket
import smtplib
import json
from configparser import ConfigParser

# set default timeout to 2 seconds
socket.setdefaulttimeout(2)

hello_world_config = '/usr/local/etc/helloworld/helloworld.conf'

result = {}
if os.path.exists(hello_world_config):
    cnf = ConfigParser()
    cnf.read(hello_world_config)
    if cnf.has_section('general'):
        try:
            smtpObj = smtplib.SMTP(cnf.get('general', 'SMTPHost'))
            msg_header = "From: " + cnf.get('general', 'FromEmail') + "\n" + \
                         "To: " + cnf.get('general', 'ToEmail') + "\n" + \
                         "Subject: " + cnf.get('general', 'Subject') + "\n" + \
                         "Test message!"

            smtpObj.sendmail(cnf.get('general', 'FromEmail'), [cnf.get('general', 'ToEmail')], msg_header)
            smtpObj.quit()
            result['message'] = 'test ok!'
        except smtplib.SMTPException as error:
            # unable to send mail
            result['message'] = '%s' % error
        except socket.error as error:
            # connect error
            if error.strerror is None:
                # probably hit timeout
                result['message'] = 'time out!'
            else:
                result['message'] = error.strerror
    else:
        # empty config
        result['message'] = 'empty configuration'
else:
    # no config
    result['message'] = 'no configuration file found'


print (json.dumps(result))
