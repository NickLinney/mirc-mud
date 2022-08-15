on 1:start: {
  unsetall
  set %commands $readini(data\commands.dat,commands,list)
}

on 1:text:@connect:#: { dcc chat $nick }

on 1:open:=: {
  set %newsession [ $+ [ $nick ] ] GetName
  query =$nick Welcome to the MUD. Please enter your character name:
}


on 1:close:=: {
  writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info seen $fulldate
  unset %newsession [ $+ [ $nick ] ]
  unset %player [ $+ [ %char [ $+ [ $nick ] ] ] ]
  unset %char [ $+ [ $nick ] ]
  unset %failedpass [ $+ [ $nick ] ]
}

on 1:chat:*: {
  if ( $istok(%commands,$1,164) == $true ) { $1 $nick $iif($2- != $null,$2-) }
  elseif ( %newsession [ $+ [ $nick ] ] == GetName ) {
    if ( $1- isalpha ) {
      set %char [ $+ [ $nick ] ] $1
      set %player [ $+ [ $1 ] ] $nick
      set %newsession [ $+ [ $nick ] ] GetPass
      if ( $exists(char\ $+ $1 $+ .chr) == $true) {
        query = [ $+ [ $nick ] ] Found your character file. Please enter your password:
      }
      else {
        copy data\charfile.dat char\ $+ $1 $+ .chr
        query = [ $+ [ $nick ] ] It looks like you don't have a character yet. I'll create a new file for you.
        query = [ $+ [ $nick ] ] Please enter your new password:
      }
    }
  }
  elseif ( %newsession [ $+ [ $nick ] ] == GetPass ) {
    if ( $readini(char\ $+ %char [ $+ [ $nick ] ],info,pass) != $null ) {
      if ( $readini(char\ $+ %char [ $+ [ $nick ] ],info,pass) == $1 ) {
        unset %newsession [ $+ [ $nick ] ]
        unset %failedpass [ $+ [ $nick ] ]
        writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info seen $fulldate
        query = [ $+ [ $nick ] ] Your password is correct.
      }
      else {
        if ( %failedpass [ $+ [ $nick ] ] == $null ) {
          set %failedpass [ $+ [ $nick ] ] 1
        }
        else {
          inc %failedpass [ $+ [ $nick ] ] 1
        }
        query = [ $+ [ $nick ] ] 4That password is incorrect. You have $calc( 7 - %failedpass [ $+ [ $nick ] ] ) tries left.
        if ( %failedpass [ $+ [ $nick ] ] == 7 ) {
          unset %failedpass [ $+ [ $nick ] ]
          set %char [ $+ [ $nick ] ] $1
          set %player [ $+ [ $1 ] ] $nick
          set %newsession [ $+ [ $nick ] ] GetPass
          query = [ $+ [ $nick ] ] 4Too many failed attempts.
          close -c $nick
        }
      }
    }
    else {
      if ( $len($1) >= 6 ) {
        set %newsession [ $+ [ $nick ] ] NewChar1
        writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info pass $1
        writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info seen $fulldate
        query = [ $+ [ $nick ] ] Okay, I got your password. It has been set to10 $1 $+ .
        query = [ $+ [ $nick ] ] Next I need you to pick your character race. You can use help races to read about the different choices.
      }
      else {
        query = [ $+ [ $nick ] ] 4That password is too short. Please make it at least 6 characters.
      }
    }
  }
  elseif ( %newsession [ $+ [ $nick ] ] == NewChar1 ) {
    if ( $istok($readini(data\races.dat,races,list),$1,164) == $true ) {
      var %racechoice, %str, %vit, %dex, %agi, %int, %wil
      %racechoice = $upper($left($1,1)) $+ $lower($right($1,$calc($len($1) - 1)))
      %str = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,str)
      %vit = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,vit)
      %dex = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,dex)
      %agi = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,agi)
      %int = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,int)
      %wil = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,wil)
      inc %str $readini(data\races.dat,%racechoice,str)
      inc %vit $readini(data\races.dat,%racechoice,vit)
      inc %dex $readini(data\races.dat,%racechoice,dex)
      inc %agi $readini(data\races.dat,%racechoice,agi)
      inc %int $readini(data\races.dat,%racechoice,int)
      inc %wil $readini(data\races.dat,%racechoice,wil)
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats str %str
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats vit %vit
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats dex %dex
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats agi %agi
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats int %int
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats wil %wil
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info race %racechoice
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr talents list $readini(data\races.dat,%racechoice,talents)
      var %x
      %x = 0
      while ( %x < $numtok($readini(data\races.dat,%racechoice,talents),164) ) {
        inc %x 1
        writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr talents $gettok($readini(data\races.dat,%racechoice,talents),%x,164) 1
      }
      query = [ $+ [ $nick ] ] Your race has been set to3 %racechoice $+ .
      query = [ $+ [ $nick ] ] Next you must choose your class. For more information, you may type help classes.
      set %newsession [ $+ [ $nick ] ] NewChar2
    }
    else {
      query = [ $+ [ $nick ] ] 4That is not a valid class. Please use help classes to see a list of all available classes.
    }
  }
  elseif ( %newsession [ $+ [ $nick ] ] == NewChar2 ) {
    if ( $istok($readini(data\classes.dat,classes,list),$1,164) == $true ) {
      var %classchoice, %str, %vit, %dex, %agi, %int, %wil, %spd
      %classchoice = $upper($left($1,1)) $+ $lower($right($1,$calc($len($1) - 1)))
      %str = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,str)
      %vit = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,vit)
      %dex = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,dex)
      %agi = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,agi)
      %int = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,int)
      %wil = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,wil)
      %spd = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,spd)
      inc %str $readini(data\classes.dat,%classchoice,str)
      inc %vit $readini(data\classes.dat,%classchoice,vit)
      inc %dex $readini(data\classes.dat,%classchoice,dex)
      inc %agi $readini(data\classes.dat,%classchoice,agi)
      inc %int $readini(data\classes.dat,%classchoice,int)
      inc %wil $readini(data\classes.dat,%classchoice,wil)
      inc %spd $readini(data\classes.dat,%classchoice,spd)
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats str %str
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats vit %vit
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats dex %dex
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats agi %agi
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats int %int
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats wil %wil
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats spd %spd
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats str %str
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats vit %vit
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats dex %dex
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats agi %agi
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats int %int
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats wil %wil
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats spd %spd
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats str %str
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats vit %vit
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats dex %dex
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats agi %agi
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats int %int
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats wil %wil
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats spd %spd
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info class %classchoice
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr classes list %classchoice
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr classes %classchoice 1
      query = [ $+ [ $nick ] ] Your class has been set to3 %classchoice $+ .
      query = [ $+ [ $nick ] ] Next you must choose your character's elemental affinity. For more information, you may type help elements.
      set %newsession [ $+ [ $nick ] ] NewChar3
    }
    else {
      query = [ $+ [ $nick ] ] 4That is not a valid class. Please use help classes to see a list of all available classes.
    }
  }
  elseif ( %newsession [ $+ [ $nick ] ] == NewChar3 ) {
    if ( $istok(Earth¤Fire¤Water¤Wind,$1,164) == $true ) {
      var %chance, %elmtchoice, %str, %vit, %dex, %agi, %int, %wil
      %chance = $rand(0,1)
      %elmtchoice = $upper($left($1,1)) $+ $lower($right($1,$calc($len($1) - 1)))
      %str = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,str)
      %vit = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,vit)
      %dex = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,dex)
      %agi = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,agi)
      %int = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,int)
      %wil = $readini(char\ $+ %char [ $+ [ $nick ] ] $+ .chr,nstats,wil)
      if ( %elmtchoice == Earth ) {
        if ( %chance == 0 ) {
          inc %vit 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats vit %vit
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats vit %vit
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats vit %vit
        }
        elseif ( %chance == 1 ) {
          inc %wil 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats wil %wil
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats wil %wil
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats wil %wil
        }
      }
      elseif ( %elmtchoice == Fire ) {
        if ( %chance == 0 ) {
          inc %str  1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats str %str
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats str %str
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats str %str
        }
        elseif ( %chance == 1 ) {
          inc %int 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats int %int
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats int %int
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats int %int
        }
      }
      elseif ( %elmtchoice == Water ) {
        if ( %chance == 0 ) {
          inc %dex 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats dex %dex
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats dex %dex
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats dex %dex
        }
        elseif ( %chance == 1 ) {
          inc %wil 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats wil %wil
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats wil %wil
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats wil %wil
        }
      }
      elseif ( %elmtchoice == Wind ) {
        if ( %chance == 0 ) {
          inc %dex 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats dex %dex
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats dex %dex
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats dex %dex
        }
        elseif ( %chance == 1 ) {
          inc %agi 1
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr nstats agi %agi
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr mstats agi %agi
          writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr cstats agi %agi
        }
      }
      writeini char\ $+ %char [ $+ [ $nick ] ] $+ .chr info element %elmtchoice
      query = [ $+ [ $nick ] ] Your element has been set to3 %elmtchoice $+ .
      query = [ $+ [ $nick ] ] Welcome to the continent of Althea!
      unset %newsession [ $+ [ $nick ] ]
    }
    else {
      query = [ $+ [ $nick ] ] 4That is not a valid element. Use help elements if you are having trouble.
    }
  }
  else { query =$nick 4Please enter a command. Use help for more info. }
}
