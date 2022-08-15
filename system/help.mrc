alias help {
  if ( $2 == $null ) {
    query = [ $+ [ $1 ] ] The help topics available are:3 $replace($readini(data\help.dat,topics,list),¤, $+ $chr(44) $+ $chr(32) $+ 3)
  }
  else {
    if ( $istok($readini(data\help.dat,topics,list),$2,164) == $true ) {
      if ( $3 == $null ) {
        if ( $readini(data\help.dat,$2,description) != $null ) {
          query = [ $+ [ $1 ] ] $readini(data\help.dat,$2,description)
        }
        query = [ $+ [ $1 ] ] The help topics available are:3 $replace($readini(data\help.dat,$2,list),¤, $+ $chr(44) $+ $chr(32) $+ 3)
      }
      else {
        if ( $istok($readini(data\help.dat,$2,list),$3,164) == $true ) {
          query = [ $+ [ $1 ] ] $readini(data\help.dat,$2,$3)
        }
        else {
          query = [ $+ [ $1 ] ] 4That is not a help topic. Please type help without any additional parameters to see a list of all topics available.
        }
      }
    }
    else {
      query = [ $+ [ $1 ] ] 4That is not a help topic. Please type help without any additional parameters to see a list of all topics available.
    }
  }
}
