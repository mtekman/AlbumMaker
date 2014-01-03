AlistChatforum (http://alistchatforum.info) Music Club Album Maker
==================================================================

Creates two zip files:
	1. Zip of properly tagged mp3 files for an album
	2. Zip of artist and track name obfuscated files for same album

Dependencies:
youtube-dl, avconv|ffmpeg, eyeD3|python-eyeD3, lame, dos2unix, zip

Create:
input/toProcess
input/tmp_uploads

In /etc/php5/apache2/php.ini:
Change:
  post_max_size = 200M
  upload_max_filesize = 20M
  max_input_time = 900

[restart]


Disable the default apache2 site:
a2dissite default

and just write a simple config in /etc/apache2/http.conf:
<VirtualHost *:80>
	Options Indexes FollowSymLinks
        DocumentRoot /var/www
        <Directory / >
        </Directory>
</VirtualHost>

This only works up to Ubuntu 13.10 so writing this config in /etc/apache2/site-available/blah.conf
is strongly encouraged, but I could not get it to work for some reason

Add cronjobs as specified in private/crontab_additions.txt to update DNS to our address and to change the password every week.
Password can be found in ~/.config/plog.txt

