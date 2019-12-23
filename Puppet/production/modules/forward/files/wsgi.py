from __future__ import absolute_import
import os

# Needed if a settings.py file exists
os.environ['PUPPETBOARD_SETTINGS'] = '/var/www/html/puppetboard/settings.py'
from puppetboard.app import app as application
application.secret_key = 'F\x97\xffE\xd45\xbc\xa0q\xf9\x1db\xe5\xbc\xa3\x15\n\x91\xed\xc2A;AG'
