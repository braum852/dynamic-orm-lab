require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    
    def self.table_name
        self.to_s.downcase.pluralize 
     end
 #creates a downcased, plural table name based on the Class Name
 
     def self.column_names
 
         sql = "PRAGMA table_info('#{table_name}')"
 
         table_info = DB[:conn].execute(sql)
         column_names = []
         table_info.each do |column|
             column_names << column["name"]
         end
         column_names.compact
     end
     #return an array of SQL column names
 
     def initialize(options={})
         options.each do |property, value|
         self.send("#{property}=", value)
         end
     end
 ##Has method that creates attr_accessors for each column name
     
     def table_name_for_insert
          self.class.table_name
     end
 #return the table name when called on an instance of Student - all part of methods for def SAVE
     def col_names_for_insert
         self.class.column_names.delete_if {|col| col == "id"}.join(", ")
     end
     #return column names without the "id" column, connects all column names as per join arg. All part of def SAVE method
 
     def values_for_insert
         values = []
         self.class.column_names.each do |col|
             values << "'#{send(col)}'" unless send(col).nil?
         end
         values.join(", ")
     end
     #formats column names to be used in SQL statement
     #Satrts by assigning empty array, column names called on by instances passed to col as args
     # which is pushed into the values (form or array) UNLESS nil column names there
     # As there is no ID value as the col_name_for_insert method, only name and grades will be updated
     #All data returns as on value, separated as per join arg(", ")
 
     def save
         sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
         DB[:conn].execute(sql)
         @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
    #Combines the above three methods to be pushed into the sql database
    #@id returns last inserted row id and saves the above data - [0][0] assigns newly saved data as first of that id
 
    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
    end
    ##executes the SQL to find a row by name

    def self.find_by(attribute_hash)
        value = attribute_hash.values.first
        formatted_value = value.class == Integer ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
        DB[:conn].execute(sql)
      end
##STUDY THIS!!
##Executes the SQL to find a row by the attribute passed into the method
##accounts for when an attribute value is an integer
end