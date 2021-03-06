#-------------------------------------------------------------------------------------------------#
# PowerShell for Devs Using SMO                                                                   #
#-------------------------------------------------------------------------------------------------#

  # Before we begin, load up the provider and SMO
  . 'C:\PS\03 - SQL\02 - Load the Provider and SMO.ps1'


#-------------------------------------------------------------------------------------------------#
# Using SMO
#-------------------------------------------------------------------------------------------------#

  # Now let's do this the SMO way!
  $machine = $env:COMPUTERNAME + "\SQL2012"  

  #-----------------------------------------------------------------------------------------------#
  # Create a database the simple way...
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest2")
  $db.Create()   

  #-----------------------------------------------------------------------------------------------#
  # ...or the more complete way
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest2") 

  $fg = New-Object Microsoft.SqlServer.Management.Smo.FileGroup ($db, 'PRIMARY')
  $db.Filegroups.Add($fg)

  $mdf = New-Object Microsoft.SqlServer.Management.Smo.DataFile($fg, "PSTest2_Data")                                        
  $fg.Files.Add($mdf)   
  $mdf.FileName = "C:\SQLdata\PSTest2_Data.mdf" 
  $mdf.Size = 30.0 * 1KB    
  $mdf.GrowthType = "Percent"  
  $mdf.Growth = 10.0       
  $mdf.IsPrimaryFile = "True" 

  $ldf = New-Object Microsoft.SqlServer.Management.Smo.LogFile($db, "PSTest2_Log")
  $db.LogFiles.Add($ldf)  
  $ldf.FileName = "C:\SQLlog\PSTest2_Log.ldf"   
  $ldf.Size = 20.0 * 1KB    
  $ldf.GrowthType = "Percent"  
  $ldf.Growth = 10.0   

  $db.Create()    

  # Prove it exists
  $Server.Databases |
    Select-Object -Property Name, Status, RecoveryModel, Owner |
    Format-Table -Autosize

##























  #-----------------------------------------------------------------------------------------------#
  # Add the table via a script
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

  $db = $Server.Databases["PSTest2"]
  # This syntax is also valid:
  #   $db = $Server.Databases.Item("PSTest2")
  
  $sql = New-Object -Type System.Collections.Specialized.StringCollection 
  $sql.Add("SET ANSI_NULLS On")  
  $sql.Add("SET QUOTED_IDENTIFIER ON") 

  $dbcmd = @"
    CREATE TABLE dbo.Sponsors
    (
        SponsorID     INT IDENTITY NOT NULL PRIMARY KEY
      , SqlSaturdayID INT NOT NULL 
      , SponsorName   NVARCHAR(100)
    )
"@

  $sql.Add($dbcmd)     

  $db.ExecuteNonQuery($sql)

  # Show its there by showing the tables collection for the database object
  $db.Tables







##



  #-----------------------------------------------------------------------------------------------#
  # Add a table with pure SMO
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $server.Databases["PSTest2"]
  $table = New-Object Microsoft.SqlServer.Management.Smo.Table($db, "SqlSaturday112")
	
  $col1 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "SqlSaturdayID")   
  $col1.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::Int
  $col1.Nullable = $false
  # In this case we don't need the SqlSaturdayID col to be an identity type, but 
  # if you did below is the code you'd need to use
  # $col1.Identity = $true
  # $col1.IdentitySeed = 1
  # $col1.IdentityIncrement = 1
  $table.Columns.Add($col1) 

  # Organizer
  $col2 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Organizer")
  $col2.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::NVarChar(100)
  $col2.Nullable = $false
  $table.Columns.Add($col2)  

  # Location
  $col3 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Location")
  $col3.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::NVarChar(100)
  $col3.Nullable = $false
  $table.Columns.Add($col3)  

  # Event
  $col4 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "EventDate")
  $col4.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::DATETIME
  $col4.Nullable = $false
  $table.Columns.Add($col4)  

  # Attendees
  $col5 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Attendees")   
  $col5.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::Int
  $col5.Nullable = $false
  $table.Columns.Add($col5) 

  $table.Create()   

  # Show its there by showing the tables collection for the database object
  $db.Tables
  

##
























  #-----------------------------------------------------------------------------------------------#
  # Add a primary key to the SQL Saturday table
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $server.Databases["PSTest2"]
  $table = $db.Tables["SqlSaturday112"] 

  $pk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "PK_SqlSaturdayId")
  $pk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey

  $ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($pk, "SqlSaturdayID")  
  $pk.IndexedColumns.Add($ic)

  $table.Indexes.Add($pk)
  $table.Alter() 

  #-----------------------------------------------------------------------------------------------#
  # Add a foriegn key from our sponsors to this new table
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $server.Databases["PSTest2"]
  $table = $db.Tables["Sponsors"] 

  $fk = New-Object `
    Microsoft.SqlServer.Management.Smo.ForeignKey($table, "FK_Sponsors_SQLSaturday112")

  $fkcol = New-Object `
    Microsoft.SqlServer.Management.Smo.ForeignKeyColumn($fk, "SqlSaturdayID", "SqlSaturdayID") 

  $fk.Columns.Add($fkcol)
  $fk.ReferencedTable = "SqlSaturday112"  
  $fk.Create()

  #-----------------------------------------------------------------------------------------------#
  # Add a unique index to the Sponsors table
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $server.Databases["PSTest2"]
  $table = $db.Tables["Sponsors"] 

  $uk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "UK_SponsorName")    
  $uk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriUniqueKey   

  $ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($uk, "SponsorName")   
  $uk.IndexedColumns.Add($ic)  
  
  $table.Indexes.Add($uk)  
  $table.Alter() 


##
























  #-----------------------------------------------------------------------------------------------#
  # Insert values into the SQL Saturday table
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $Server.Databases["PSTest2"]
  $dbcmd = @"
    INSERT INTO dbo.SqlSaturday112
      (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
    VALUES
      (112, 'John Baldwin', 'Birmingham, AL', '2012/05/12', 150)
    , (141, 'Adam Curry', 'Austin, TX', '2012/06/16', 141)
    , (132, 'John C Dvorak', 'San Francisco, CA', '2012/06/09', 132)
    , (150, 'Patrick LeBlanc', 'Baton Rouge, LA', '2012/08/04', 150)
    , (151, 'Andy Warren', 'Orlando, FL', '2012/09/29', 151)
    , (144, 'Louis Davidson', 'Nashville, TN', '2012/10/13', 144)
"@

  $db.ExecuteNonQuery($dbcmd)



  #-----------------------------------------------------------------------------------------------#
  # Now read that data back 
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $Server.Databases["PSTest2"]

  $dbcmd = @"
    SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
      FROM dbo.SqlSaturday112
     ORDER BY Attendees DESC
"@

  # Returns a System.Data.DataSet
  $data = $db.ExecuteWithResults($dbcmd)    

  # Datasets can contain 1 or more DataTable objects in
  # their Tables collection. 
  # In this case we only have 1, so we can just grab it
  # using the numerical array access technique
  $dt = New-Object "System.Data.DataTable"  
  $dt = $data.Tables[0]

  $dt | Get-Member

  # Show our rows
  $dt | Format-Table -Autosize   

  # Each $row is a System.Data.DataRow object  
  foreach($row in $dt)
  {
    $row.Organizer
  }


##
















  #-----------------------------------------------------------------------------------------------#
  # Update a row
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $db = $Server.Databases["PSTest2"]

  $dbcmd = @"
    UPDATE dbo.SqlSaturday112
       SET Attendees = 999
     WHERE SqlSaturdayID = 112
"@

  $db.ExecuteNonQuery($dbcmd)

  # Read the row we updated
  $dbcmd = @"
    SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
      FROM dbo.SqlSaturday112
     WHERE SqlSaturdayID = 112
"@

  $data = $db.ExecuteWithResults($dbcmd)    
  $data.Tables[0] | Format-Table -Autosize   


  #-----------------------------------------------------------------------------------------------#
  # Drop the database
  #-----------------------------------------------------------------------------------------------#
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
  $Server.KillAllProcesses("PSTest2")
  $Server.KillDatabase("PSTest2")

  # Show it went bye-bye
  $Server.Databases |
    Select-Object -Property Name, Status, RecoveryModel, Owner |
    Format-Table -Autosize

##













###


















# Mention Encode-SQLName