
require_relative 'Project'

class String
  def is_integer?
    self.to_i.to_s == self
  end
end 

class PlanProject < Project
  require 'nokogiri'
  attr :mtpid, :secondary_improvement_types

  def nodeset_content(nodeset)
    a = nodeset.map {|e| e.content}
  end

  def initialize(node)
    self.set_vars
    c = node.children
    @vars.each do |k, v|
      case v[1]
      when 'string'
        value = c.css(v[0]).first.content
        value.gsub! "'", "`"
        value.gsub! "\"", "`"
      when 'int'
        value = c.css(v[0]).first.content.empty? ? 'NULL' : c.css(v[0]).first.content.to_i
      when 'decimal'
        value = c.css(v[0]).first.content.empty? ? 'NULL' : c.css(v[0]).first.content.to_f
      when 'bit'
        value = c.css(v[0]).first.content == 'true' ? 1 : 0
      end
      instance_variable_set("@#{k}", value)
    end
    @contact_name = @contact_first_name + ' ' + @contact_last_name
    @start_year = c.css('start-year').first.content[0,4]
    @mtp_status == 0 ? @mtp_status = 'NULL' : @mtp_status
    s_i_t = c.css('secondary-improvement-types').children 
    @secondary_improvement_types = nodeset_content(s_i_t.css('number').children)
  end
  
  def import_qry

    begin
      qry = <<-QUERY 
      EXEC mtpsp_ImportToStaging
      #{@mtpid},'#{@title}','#{@description}',#{@tot_proj_cost},
      '#{@contact_name}','#{@contact_phone}','#{@contact_email}',#{@est_cost_year},
      #{@completion_year},#{@mtp_status},'#{@project_on}','#{@project_from}',
      '#{@project_to}',#{@mile_post_from},#{@mile_post_to},#{@county_id},
      #{@func_class_id},
      #{@start_year},'#{@primary_improvement_type_id}',#{@p_a1a},#{@p_a1b},#{@p_a2a},#{@p_a2b},#{@p_a3},#{@p_a4},
      #{@p_c1a},#{@p_c1b},#{@p_c1c},#{@p_c2a},#{@p_c2b},#{@p_c3},#{@p_c4},#{@p_c5},
      #{@p_f1},#{@p_f2}, #{@p_f3},#{@p_f4a},#{@p_f4b},#{@p_f5},#{@p_f6},
      #{@p_j1a},#{@p_j1b},#{@p_j2}, #{@p_j3},#{@p_j4},
      #{@p_m1},#{@p_m2},#{@p_m3},#{@p_m4},#{@p_m5},#{@p_m6},#{@p_m7},
      #{@p_o1},#{@p_o2a},#{@p_o2b},#{@p_o2c},#{@p_o3a},#{@p_o3b},#{@p_o3c},
      #{@p_s1a},#{@p_s1b},#{@p_s1c},#{@p_s2},
      #{@p_t1},#{@p_t2},#{@p_t3},#{@p_t4},
      #{@p_w1a},#{@p_w1b},#{@p_w1c},#{@p_w1d},#{@p_w2},#{@p_w4a},#{@p_w4b}
      QUERY
      
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end 

  def secondary_improvement_type_query
    initial_query = <<-QUERY
      INSERT INTO tblStageProj_ImpType (MTPID, isPrimary, OldID) 
      VALUES
    QUERY
    qry = @secondary_improvement_types.inject(initial_query) do |m, t|
      t="#{m}(#{@mtpid},0,'#{t}'),"
    end
    qry.chop
  end

end

class Submissions
  require 'open-uri'
  require 'nokogiri'
  require 'active_support/core_ext'
  attr :xml_doc, :projects
  
  def initialize(filepath)
    xml = open(filepath)
    @xml_doc = Nokogiri::XML(xml)
  end

  def parse
    item_nodes = @xml_doc.xpath('//mtp-projects/mtp-project')
    projects = item_nodes.map {|node| PlanProject.new(node) }
  end
end


class DbConn

  def initialize(db)
    @connection = "SQLCMD -S SQL2008\\\PSRCSQL -E -d #{db} -r -Q "
  end

  def execute_query(qry)
    begin
      combined_command = @connection + "\"" + qry + "\""
      combined_command.gsub!(/\n/,' ')
      query_output = `#{combined_command}`
      raise "An error occurred in DbConn.execute_query: #{qry}" if query_output.empty?
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      File.open('mtp_project_out.txt', 'a') {|file| file.write("\nFAILED QUERY: #{combined_command}\n")}
    end
  end
end

mtp_submissions = Submissions.new('mtp_projects.xml'); nil;
conn = DbConn.new('MTPData_dev')
#Need to check for duplicate projects in XML here before continuing on
conn.execute_query('EXEC mtpsp_DeleteFromStagingTables')
p = mtp_submissions.parse; nil;
p.each do |project|
  q = project.import_qry
  # File.open('mtp_project_out.txt', 'a') {|file| file.write("\nQUERY: #{q}\n")}
  conn.execute_query(q)
  secondary_improvement_type_query = project.secondary_improvement_type_query
  # File.open('mtp_project_out.txt', 'a') {|file| file.write("\nImp Type QUERY: #{secondary_improvement_type_query}\n")}
  conn.execute_query(secondary_improvement_type_query) if project.secondary_improvement_types.length > 0
  puts "imported project #{project.mtpid}"
end
conn.execute_query('mtpsp_StageToReview 14')
puts "Finished importing."