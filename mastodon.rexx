/* REXX */

CREATOR = 'BREXXTODON BY Soldier of FORTRAN'

/* IMPORT THE API LIBRARY */
CALL IMPORT FSSAPI

/* ADDRESS THE FSS SUBSYSTEM */
ADDRESS FSS

if EXISTS('MASTODON') = 0 then do
  /* We need to prompt the user to enter their credentials */
  CALL NO_MASTODON_INFO
end

PARMLIB = OPEN('MASTODON','r')
if PARMLIB < 0 THEN do
  rc=rxmsg(001,'E','Unable to open' USERID()||.'MASTODON')
  exit 8
end
PROXY_STRING = LINEIN(PARMLIB,1)
MASTODON_SERVER = LINEIN(PARMLIB,2)
ACCESS_TOKEN = LINEIN(PARMLIB,3)
RC = CLOSE(PARMLIB)

IF LENGTH(PROXY_STRING) = 0 |,
    LENGTH(MASTODON_SERVER) = 0 |,
    LENGTH(ACCESS_TOKEN) = 0 THEN DO
    msg = 'Delete' USERID()||'.MASTODON and try again'
  rc=rxmsg(002,'E','Missing entries in parmlib. '||msg)
  exit 8
end

CALL INIT_TOOTS

/* do i = 1 to toots.0
say 'connecting to' MASTODON_SERVER
  if toots.i.reblogged then do
  say 'Toot by:' toots.i.rdisplay_name,
   toots.i.rusername toots.i.date
  say ''
  say toots.i.content
  say ''
  say 'Boosted by:' toots.i.display_name toots.i.username
  end
  else do
    say 'Toot by:' toots.i.display_name,
    toots.i.username toots.i.date
  say ''
  say toots.i.content
  end
  say '--------------------------'
end */


EXIT

INIT_TOOTS:
  CALL FSSINIT
  CALL FSSTITLE 'GETTING TOOTS', #BLUE

  elephant.1  = "                            _"
  elephant.2  = "                          .' `'.__"
  elephant.3  = "                         /      \ `''-,"
  elephant.4  = "        .-''''--...__..-/ .     |      \"
  elephant.5  = "      .'               ; :'     '.  M   |"
  elephant.6  = "     /                 | :.       \     =\"
  elephant.7  = "    ;                   \':.      /  ,-.__;.-;`"
  elephant.8  = "   /|     .              '--._   /-.7`._..-;`"
  elephant.9  = "  ; |       '                |`-'      \  =|"
  elephant.10 = "  |/\        .   -' /     /  ;         |  =/"
  elephant.11 = "  (( ;.       ,_  .:|     | /     /\   | =|"
  elephant.12 = '   ) / `\     | `""`;     / |    | /   / =/'
  elephant.13 = "     | ::|    |      \    \ \    \ `--' =/"
  elephant.14 = "    /  '/\    /       )    |/     `-...-`"
  elephant.15 = "   /    | |  `\    /-'    /;"
  elephant.16 = "   \  ,,/ |    \   D    .'  \"
  elephant.17 = '    `""`   \  nnh  D_.-"L__nnh'
  elephant.18 = '            `"""`'

  DO I=1 TO 18
    CALL FSSTEXT elephant.I,4+I,4,,#PROT+#TURQ
  END
  CALL FSSTEXT 'Press Enter To Continue',11,54,,#PROT+#RED
  CALL FSSTEXT 'Press F3 To Quit',12,54,,#PROT+#RED
  CALL FSSTEXT 'Mastodon Server :' MASTODON_SERVER,3,4,,#PROT+#BLUE
  CALL FSSTEXT 'Proxy Server    :' PROXY_STRING,4,4,,#PROT+#BLUE
  CALL FSSTEXT CREATOR,FSSHeight(),FSSWidth()-LENGTH(CREATOR),,#PROT+#GREEN
 
  RCKEY=FSSREFRESH()
  IF RCKEY==#PFK03 | RCKEY==#PFK15 THEN return
  CALL FSSCLOSE
  CALL SHOW_TOOTS
return

SHOW_TOOTS:
  CALL FSSINIT
  CALL FSSTITLE MASTODON_SERVER, #BLUE
  CALL FSSTEXT 'PRESS F3 To Exit',FSSHEIGHT(),1,,#PROT+#BLUE

  DO FOREVER
    x=memory('NOPRINT')
    call wto 'Before Mastodon' x
    json = get_toots(PROXY_STRING,MASTODON_SERVER,ACCESS_TOKEN)
    call parse_json json
    x=memory('NOPRINT')
    call wto 'After Mastodon' x
    line_num = 3
    do i = 1 to toots.0
      if toots.i.reblogged then do
        tusername = toots.i.rusername
        dname = toots.i.rdisplay_name
      end
      else do
        tusername = toots.i.username
        dname = toots.i.display_name
      end
      tdate = toots.i.date
        /* show the header */
      CALL FSSTEXT dname '(' tusername ')',line_num,1,,#PROT+#YELLOW
      CALL FSSTEXT tdate,line_num,FSSWidth()-LENGTH(tdate),,#PROT+#WHITE
       /* show the toot */
      line_num = line_num + 1
      total_toot = strip(toots.i.content,'B','"')
      toot_line = ''
      do while length(total_toot) > 0
        parse var total_toot word total_toot
        if (length(toot_line) + length(word) + 1) > (FSSWIDTH() - 2) then do
          CALL FSSTEXT toot_line,line_num,1,,#PROT+#TURQ
          line_num = line_num + 1
          toot_line = ''
        end
        call wto 'TOOT LINE' toot_line
        toot_line = toot_line word
        /* line is too long we need to split it */
        do while length(toot_line) > (FSSWIDTH() - 2)
          split_line = LEFT(toot_line,FSSWIDTH() - 2)
          CALL FSSTEXT split_line,line_num,1,,#PROT+#TURQ
          line_num = line_num + 1
          toot_line = RIGHT(toot_line,(length(toot_line) - (FSSWIDTH() - 2)))
        end
      end
      if length(toot_line) > 0 then do
        CALL FSSTEXT toot_line,line_num,1,,#PROT+#TURQ
        line_num = line_num + 1
      end
       /* show who boosted */
      if toots.i.reblogged then do
        booster = 'Boosted:' toots.i.display_name 
        call FSSTEXT booster,line_num,1,,#PROT+#BLUE
        line_num = line_num + 1
      end
      line_num = line_num + 1
    end
    RCKEY=FSSREFRESH()
    IF RCKEY==#PFK03 | RCKEY==#PFK15 | RCKEY==#ENTER THEN LEAVE
  END
  CALL FSSCLOSE

return

NO_MASTODON_INFO:
  CALL FSSINIT
  CALL GET_MASTODON_INFO

  DO FOREVER
     /* UPDATE FIELD VALUES */
  /* CALL UPDATE */
     /* REFRESH / SHOW SCREEN */
    RCKEY=FSSREFRESH()
    IF RCKEY==#PFK03 | RCKEY==#PFK15 THEN LEAVE
    PROXY_STRING = STRIP(FSSFGET('_PROXY'))
    MASTODON_SERVER = STRIP(FSSFGET('_INSTANCE'))
    ACCESS_TOKEN = STRIP(FSSFGET('_KEY'))
    errmsg = 'ERR: complete all fields'
    field_err = 0
    if length(PROXY_STRING) = 0 then field_err = 1
    if length(MASTODON_SERVER) = 0 then field_err = 1
    if length(ACCESS_TOKEN) = 0 then field_err = 1
    if field_err then do
      CALL FSSZERRSM errmsg
      iterate
    end
    else leave
  END
  CALL FSSCLOSE
    /* Then we create the dataset */
  STR = 'DSORG=PS,RECFM=FB,BLKSIZE=3120,LRECL=80,PRI=1,SEC=1,UNIT=SYSDA'
  RC = CREATE('MASTODON',STR)
  if RC < 0 THEN do
    rc=rxmsg(001,'E','Unable to create' USERID()||.'MASTODON')
    exit 8
  end
  PARMLIB = OPEN('MASTODON','w')
  if PARMLIB < 0 THEN do
    rc=rxmsg(001,'E','Unable to open' USERID()||.'MASTODON')
    exit 8
  end
  CALL LINEOUT PARMLIB,PROXY_STRING,1
  CALL LINEOUT PARMLIB,MASTODON_SERVER,2
  CALL LINEOUT PARMLIB,ACCESS_TOKEN,3
  RC = CLOSE(PARMLIB)


RETURN

GET_MASTODON_INFO:

  s.1 = "Welcome to the Mastodon MVS client."||,
  " To use this client we need to"
  s.2 = "collect some information. Brexx doesn't"||,
  " support TLS so you'll need to"
  s.3 = "setup your own proxy, WebOne works really"||,
  " well for this. Once setup"
  s.4 = "place the proxy address and port in the "||,
  "proxy address field."
  s.5 = ' '
  s.6 ="This script also needs your Mastodon instance"||,
  " and your access key. You"
  s.7 ="can generate an access key by going to "||,
  "Preferences -> Development and"
  s.8 ="clicking on 'New Application'. I strongly "||,
  "recommend you only allow this"
  s.9 ="script access to 'read:statuses'. Copy and "||,
  "paste the key under 'Your"
  s.10 ="access token' to the Access Keyfield below."||,
  " When done hit enter."
  s.11 = ' '
  s.12 = "You only need to do this once. The file '"USERID()".MASTODON'"
  s.13 = "will store this information."

   CALL FSSTITLE 'MASTODON SETUP', #BLUE

  DO I=1 TO 13
    CALL FSSTEXT S.I,2+I,4,,#PROT+#WHITE
  END

  CALL FSSTEXT 'Proxy Address',6,44,,#PROT+#GREEN
  CALL FSSTEXT 'Proxy Address:',17,4,,#PROT+#GREEN
  CALL FSSTEXT 'Mastodon Instance',8,32,,#PROT+#TURQ
  CALL FSSTEXT 'Mastodon Instance:',19,4,,#PROT+#TURQ
  CALL FSSTEXT 'Acces Key',12,25,,#PROT+#PINK
  CALL FSSTEXT 'Acces Key:',21,4,,#PROT+#PINK
  CALL FSSFIELD '_PROXY',17,20,59,#HI+#GREEN+#USCORE, ''
  CALL FSSFIELD '_INSTANCE',19,24,55,#HI+#TURQ+#USCORE, ''
  CALL FSSFIELD '_KEY',21,16,63,#HI+#PINK+#USCORE, ''
  CALL FSSTEXT 'PRESS F3 To Exit',FSSHEIGHT(),1,,#PROT+#BLUE
return

strip_key: procedure
    /* strips the key from the json entry */
    parse arg in_string
    return strip(substr(in_string,pos('":', in_string)+2),,'"')


strip_html: procedure
  /* strips html tags from content */
  /* also strips non printable characters and translate htmlisms */
  parse arg content_in
  /* content_in = translate(content_in,'3E'x,'>')  */
  content_in = changestr(X2C('3C'), content_in, '<')
  content_in = changestr(X2C('3E'), content_in, '>')
  content_in = changestr(X2C('26'), content_in, '&')
  content_in = changestr(X2C('4A'), content_in, '[')
  content_in = changestr(X2C('5A'), content_in, ']')

  /* this is just dirty */
  content_in = changestr('<p>', content_in, ' ')
  content_in = changestr('<br>', content_in, ' ')
  content_in = changestr('<br/>', content_in, ' ')
  content_in = changestr('<br />', content_in, ' ')
  /* yuk */

  content_out = ''
  do while length(content_in) > 0
    parse var content_in c +1 content_in
    if c = "<" then do
        do until c = ">"
            parse var content_in c +1 content_in
        end
        iterate /* skip lingering > */
    end
    content_out = content_out || c
  end


  content_out = changestr('&quot;', content_out, '"')
  content_out = changestr('&#39;', content_out, "'")
  content_out = changestr('&amp;', content_out, '&')
  content_out = changestr('&gt;', content_out, '')
  content_out = changestr('&lt;', content_out, '')

  return clean_that_string(content_out)


clean_that_string: procedure
  /* takes a string and removes non printable chars */
  parse arg dirty_string
  special_c ='!"#$%&()*+,-./:;<=>?@[\]^_`{|}~'||"''"
  valid_chars = 'abcdefghijklmnopqrstuvwxyz'||,
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ'||,
                '0123456789'||special_c

  invalid_chars = SPACE( TRANSLATE( XRANGE(),, valid_chars ),0)
  fixed = SPACE(TRANSLATE( dirty_string,, invalid_chars ),1)

return fixed

assemble_content: procedure
  /* This procedure goes through the content and convert escaped
     unicode to characters */
  parse arg content_in
  content_out = ''
  do while length(content_in) > 0
      if left(content_in,2) = "\u" then do
          parse var content_in c +6 content_in
          c = eu2e(c)
      end
      else parse var content_in c +1 content_in
      content_out = content_out || c
  end

return content_out

eu2e: procedure
  /* converts escaped unicode to ebcdic */
  parse arg escaped_unicode
  hex = right(escaped_unicode,2)
  /* return blank if its outside the ascii range */
  if x2d(hex) > 126 | x2d(hex) < 32 then return ''
  ebcdic = x2c(hex)
return ebcdic

get_toots: procedure
  parse arg PROXY,MASTODON_SERVER,ACCESS_TOKEN

  /* constants/defaults */
  CRLF = '0D25'x
  PATH = '/api/v1/timelines/home?limit=4'
  TIMEOUT = 5

  if pos('http://',PROXY) = 1 then
    parse var PROXY 'http://' HOST ':' PORT
  else
    parse var PROXY HOST ':' PORT

  if pos('http://',MASTODON_SERVER) = 1 then
    parse var MASTODON_SERVER 'http://' MASTODON_SERVER
  else if pos('https://',MASTODON_SERVER) = 1 then
    parse var MASTODON_SERVER 'https://' MASTODON_SERVER

  if length(PORT) = 0 then PORT = 80

  /* Builing HTTP request */
  GET    = 'GET /http://'||MASTODON_SERVER||PATH 'HTTP/1.1'
  HHOST   = 'Host:' HOST||':'||PORT
  AGENT  = 'User-Agent: brexxtodon/0.0.1'
  ACCEPT = 'Accept: */*'
  BEARER = 'Authorization: Bearer' ACCESS_TOKEN


  httpget = GET    ||CRLF||,
            HHOST  ||CRLF||,
            AGENT  ||CRLF||,
            ACCEPT ||CRLF||,
            BEARER ||CRLF||,
            CRLF

  /* Connect */

  CALL TCPINIT()
  rc = TCPOPEN(host, port, 15)
    if rc < 0 then do
      return 'ERROR Could not connect to' HOST||':'||PORT
    end
  socket_id = _FD

  /* send http request */
  rc = TCPSEND(socket_id, E2A(httpget), TIMEOUT)
  if rc < 0 then do
    return 'ERROR Could not send request to' HOST||':'||PORT
  end

  recv_size = TCPReceive(socket_id, TIMEOUT)
  if recv_size < 0 then return 'ERROR Could not receive data' recv_size

  recvd = _Data

  do while recv_size > 0
    recv_size = TCPReceive(socket_id, TIMEOUT)
    if recv_size > 0 then recvd = recvd || _Data
  end

  html_data = A2E(recvd)

  CALL TCPCLOSE(socket_id)
  CALL TCPTERM()

  lines = 1

  /* we need to first parse CR and LF chars then just LF on their own */
  do while length(html_data) > 0
    parse var html_data line '0D25'x html_data
    output.lines = line
    lines = lines + 1
  end

  output.0 = lines

  if datatype(output.0) \= 'NUM' then do
      return 'ERROR Invalid Number of HTTP lines'
  end

  /* HTTP/1.1 200 OK */
  if pos('HTTP',output.1) = 0 then do
      return 'ERROR HTTP Header missing'
  end

  parse var output.1 . '/' HTTP_VERSION RESPONSE_CODE .

  if RESPONSE_CODE \= '200' then
    return 'ERROR Invalid HTTP Response:' output.1

  header_line = 1

  do i=2 to output.0
      if length(output.i) = 0 then LEAVE

      header.header_line = output.i
      header_line = header_line + 1
  end

  header.0 = header_line

  total = i

  html_line = 1
  do i = total to (output.0 - 1)
      line = output.i
      do while length(line) > 0
          parse var line l '25'x line
          html.html_line = l
          html_line = html_line + 1
      end
  end
  html.0 = html_line

  if length(html.1) = 0 then return 'ERROR No JSON content'

return html.1

parse_json:
/*
  takes in mastodon json and dirtily makes a stem
  with the format:
  toots.0 = number of toots
  toots.1.date = the date of the toot
  toots.1.reblogged (1 for yes 0 for no)
  toots.1.username
  toots.1.acct
  toots.1.display_name
  toots.1.content
  if reblogged:
    toots.1.rusername
    toots.1.racct
    toots.1.rdisplay_name
  toots.2 etc to toots.0

*/
parse arg mjson

total_toots = 0

do while pos('"created_at"',mjson) > 0
  created_at_pos = pos('"created_at"',mjson)
  reblogged_pos = pos('"reblog":{',mjson)
  content_pos = pos('"content":',mjson)
  username_pos = pos('"username":',mjson)
  display_name_pos = pos('"display_name":',mjson)
  acct_pos = pos('"acct":',mjson)
  reblogged = 0

  if content_pos = 0 then leave
  total_toots = total_toots + 1

  mcreated_at = substr(mjson, created_at_pos,,
                pos('",',mjson,created_at_pos) - created_at_pos+1)

  mcontent = substr(mjson, content_pos + 10,,
            pos('",',mjson,content_pos) - content_pos - 9)

  musername = substr(mjson, username_pos,,
              pos('",',mjson,username_pos) - username_pos + 1 )

  mdisplay_name = substr(mjson, display_name_pos,,
              pos('",',mjson,display_name_pos) - display_name_pos + 1 )

  macct = substr(mjson, acct_pos,,
              pos('",',mjson,acct_pos) - acct_pos + 1 )

  if reblogged_pos > 0 & mcontent = '""' then do
  /* TO DO: fix when the content is nothing cause its an image
            only post, it messes with reblogs */
    /* this is a reblog so we have to re do it all again */
    rusername = musername
    racct = macct
    rdisplay_name = mdisplay_name

    mjson = substr(mjson,reblogged_pos)
    rcreated_at_pos = pos('"created_at"',mjson)
    rcontent_pos = pos('"content":',mjson)

    rcontent = substr(mjson,,
                rcontent_pos + 10,,
                pos('",',mjson,rcontent_pos) - rcontent_pos - 9)

    rcreated_at = substr(mjson, rcreated_at_pos,,
              pos('",',mjson,rcreated_at_pos) - rcreated_at_pos+1)

    mjson = substr(mjson,pos('"poll":', mjson) + 7)
    username_pos = pos('"username":',mjson)
    display_name_pos = pos('"display_name":',mjson)
    acct_pos = pos('"acct":',mjson)

    musername = substr(mjson, username_pos,,
              pos('",',mjson,username_pos) - username_pos + 1 )

    mdisplay_name = substr(mjson, display_name_pos,,
              pos('",',mjson,display_name_pos) - display_name_pos + 1 )

    macct = substr(mjson, acct_pos,,
              pos('",',mjson,acct_pos) - acct_pos + 1 )

    mcontent =changestr('\"',strip_html(assemble_content(rcontent)),'"')

    toots.total_toots.reblogged     = 1
    toots.total_toots.content       = mcontent

    /* these are the account who reblogged */
  toots.total_toots.date        = clean_that_string(strip_key(mcreated_at))
  toots.total_toots.username    = clean_that_string(strip_key(musername))
  toots.total_toots.acct        = clean_that_string(strip_key(macct))
  toots.total_toots.display_name  = clean_that_string(strip_key(mdisplay_name))
    /* these are the original poster */
 toots.total_toots.rdate       = clean_that_string(strip_key(rcreated_at))
 toots.total_toots.rusername   = clean_that_string(strip_key(rusername))
 toots.total_toots.racct       = clean_that_string(strip_key(racct))
 toots.total_toots.rdisplay_name = clean_that_string(strip_key(rdisplay_name))
  end
  else do
    /* regular toot */
    mcontent =changestr('\"',strip_html(assemble_content(mcontent)),'"')

    toots.total_toots.reblogged    = 0
    toots.total_toots.date         = clean_that_string(strip_key(mcreated_at))
    toots.total_toots.username     = clean_that_string(strip_key(musername))
    toots.total_toots.acct         = clean_that_string(strip_key(macct))
  toots.total_toots.display_name = clean_that_string(strip_key(mdisplay_name))
    toots.total_toots.content      = mcontent


  end

  mjson = substr(mjson,pos('"poll":', mjson) + 7)
end

toots.0 = total_toots

return