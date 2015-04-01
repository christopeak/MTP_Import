class PlanProject
  require 'nokogiri'
  attr :mtpid, :title, :description, :tot_proj_cost, :contact_first_name
  attr :contact_name, :contact_phone, :contact_email, :est_cost_year
  attr :completion_year, :mtp_status, :project_on, :project_from
  attr :project_to, :mile_post_from, :mile_post_to, :func_class_id
  attr :start_year, :qry
  
  def initialize(node)
    c = node.children
    @mtpid = c.css('project-id').first.content.to_i
    @title = c.css('title').first.content
    @title.gsub!("'",'`')
    @title.gsub!('"','`')
    @description = c.css('description').first.content
    @description.gsub!("'",'`')
    @description.gsub!('"','`')
    @tot_proj_cost = c.css('total-cost').first.content.to_i
    contact_first_name = c.css('contact-first-name').first.content
    contact_last_name = c.css('contact-last-name').first.content
    @contact_name = contact_first_name + ' ' + contact_last_name
    @contact_phone = c.css('contact-phone').first.content
    @contact_email = c.css('contact-email').first.content
    @est_cost_year = c.css('constant-dollar-year').first.content.to_i
    @completion_year = c.css('completion-year').first.content.to_i
    @mtp_status = c.css('mtp-status').first.content
    @project_on = c.css('location').first.content
    @project_from = c.css('endpoint-a').first.content
    @project_to = c.css('endpoint-b').first.content
    @mile_post_from = c.css('milepost-a').first.content.empty? ? 'NULL' : c.css('milepost-a').first.content
    @mile_post_to = c.css('milepost-b').first.content.empty? ? 'NULL' : c.css('milepost-b').first.content
    @county_id = c.css('county-id').first.content.empty? ? 'NULL' : c.css('county-id').first.content
    @func_class_id = c.css('functional-class').first.content.empty? ? 'NULL' : c.css('functional-class').first.content
    @start_year = c.css('start-year').first.content[0,4]
    @p_a1a = c.css('prioritization-a1a').first.content == 'true' ? 1 : 0
    @p_a1b = c.css("prioritization-a1b").first.content == 'true' ? 1 : 0
    @p_a2a = c.css("prioritization-a2a").first.content== 'true'  ? 1 : 0
    @p_a2b = c.css("prioritization-a2b").first.content == 'true'  ? 1 : 0
    @p_a3 = c.css("prioritization-a3").first.content == 'true' ? 1 : 0
    @p_a4 = c.css("prioritization-a4").first.content == 'true' ? 1 : 0
    @p_c1a = c.css("prioritization-c1a").first.content == 'true' ? 1 : 0
    @p_c1b = c.css("prioritization-c1c").first.content == 'true' ? 1 : 0
    @p_c1c = c.css("prioritization-c1d").first.content == 'true' ? 1 : 0
    @p_c2a = c.css("prioritization-c2a").first.content == 'true' ? 1 : 0
    @p_c2b = c.css("prioritization-c2b").first.content == 'true' ? 1 : 0
    @p_c3 = c.css("prioritization-c3").first.content == 'true' ? 1 : 0
    @p_c4 = c.css("prioritization-c4").first.content == 'true' ? 1 : 0
    @p_c5 = c.css("prioritization-c5").first.content == 'true' ? 1 : 0
    @p_f1 = c.css("prioritization-f1").first.content == 'true' ? 1 : 0
    @p_f2 = c.css("prioritization-f2").first.content == 'true' ? 1 : 0
    @p_f3 = c.css("prioritization-f3").first.content == 'true' ? 1 : 0
    @p_f4a = c.css("prioritization-f4a").first.content == 'true' ? 1 : 0
    @p_f4b = c.css("prioritization-f4b").first.content == 'true' ? 1 : 0
    @p_f5 = c.css("prioritization-f5").first.content == 'true' ? 1 : 0
    @p_f6 = c.css("prioritization-f6").first.content == 'true' ? 1 : 0
    @p_j1a = c.css("prioritization-j1a").first.content == 'true' ? 1 : 0
    @p_j1b = c.css("prioritization-j1b").first.content == 'true' ? 1 : 0
    @p_j2 = c.css("prioritization-j2").first.content == 'true' ? 1 : 0
    @p_j3 = c.css("prioritization-j3").first.content == 'true' ? 1 : 0
    @p_j4 = c.css("prioritization-j4").first.content == 'true' ? 1 : 0
    @p_m1 = c.css("prioritization-m1").first.content == 'true' ? 1 : 0
    @p_m2 = c.css("prioritization-m2").first.content == 'true' ? 1 : 0
    @p_m3 = c.css("prioritization-m3").first.content == 'true' ? 1 : 0
    @p_m4 = c.css("prioritization-m4").first.content == 'true' ? 1 : 0
    @p_m5 = c.css("prioritization-m5").first.content == 'true' ? 1 : 0
    @p_m6 = c.css("prioritization-m6").first.content == 'true' ? 1 : 0
    @p_m7 = c.css("prioritization-m7").first.content == 'true' ? 1 : 0
    @p_o1 = c.css("prioritization-o1").first.content == 'true' ? 1 : 0
    @p_o2a = c.css("prioritization-o2a").first.content == 'true' ? 1 : 0
    @p_o2b = c.css("prioritization-o2b").first.content == 'true' ? 1 : 0
    @p_o2c = c.css("prioritization-o2c").first.content == 'true' ? 1 : 0
    @p_o3a = c.css("prioritization-o3a").first.content == 'true' ? 1 : 0
    @p_o3b = c.css("prioritization-o3b").first.content == 'true' ? 1 : 0
    @p_o3c = c.css("prioritization-o3c").first.content == 'true' ? 1 : 0
    @p_s1a = c.css("prioritization-s1a").first.content == 'true' ? 1 : 0
    @p_s1b = c.css("prioritization-s1b").first.content == 'true' ? 1 : 0
    @p_s1c = c.css("prioritization-s1c").first.content == 'true' ? 1 : 0
    @p_s2 = c.css("prioritization-s2").first.content == 'true' ? 1 : 0
    @p_t1 = c.css("prioritization-t1").first.content == 'true' ? 1 : 0
    @p_t2 = c.css("prioritization-t2").first.content == 'true' ? 1 : 0
    @p_t3 = c.css("prioritization-t3").first.content == 'true' ? 1 : 0
    @p_t4 = c.css("prioritization-t4").first.content == 'true' ? 1 : 0
    @p_w1a = c.css("prioritization-w1a").first.content == 'true' ? 1 : 0
    @p_w1b = c.css("prioritization-w1b").first.content == 'true' ? 1 : 0
    @p_w1c = c.css("prioritization-w1c").first.content == 'true' ? 1 : 0
    @p_w1d = c.css("prioritization-w1d").first.content == 'true' ? 1 : 0
    @p_w2 = c.css("prioritization-w2").first.content == 'true' ? 1 : 0
    @p_w4a = c.css("prioritization-w4a").first.content == 'true' ? 1 : 0
    @p_w4b = c.css("prioritization-w4b").first.content == 'true' ? 1 : 0
  end
  
  def send_to_db
    #create an input query and fire it off to SQL Server via shell command
    db = 'MTPData_dev'

    command = "SQLCMD -S SQL2008\\\PSRCSQL -E -d #{db} -Q"


    @qry = <<-QUERY 
    "EXEC mtpsp_ImportToStaging
    #{@mtpid},'#{@title}','#{@description}',#{@tot_proj_cost},
    '#{@contact_name}','#{@contact_phone}','#{@contact_email}',#{@est_cost_year},
    #{@completion_year},#{@mtp_status},'#{@project_on}','#{@project_from}',
    '#{@project_to}',#{@mile_post_from},#{@mile_post_to},#{@county_id},
    #{@func_class_id},
    #{@start_year},#{@p_a1a},#{@p_a1b},#{@p_a2a},#{@p_a2b},#{@p_a3},#{@p_a4},
    #{@p_c1a},#{@p_c1b},#{@p_c1c},#{@p_c2a},#{@p_c2b},#{@p_c3},#{@p_c4},#{@p_c5},
    #{@p_f1},#{@p_f2}, #{@p_f3},#{@p_f4a},#{@p_f4b},#{@p_f5},#{@p_f6},
    #{@p_j1a},#{@p_j1b},#{@p_j2}, #{@p_j3},#{@p_j4},
    #{@p_m1},#{@p_m2},#{@p_m3},#{@p_m4},#{@p_m5},#{@p_m6},#{@p_m7},
    #{@p_o1},#{@p_o2a},#{@p_o2b},#{@p_o2c},#{@p_o3a},#{@p_o3b},#{@p_o3c},
    #{@p_s1a},#{@p_s1b},#{@p_s1c},#{@p_s2},
    #{@p_t1},#{@p_t2},#{@p_t3},#{@p_t4},
    #{@p_w1a},#{@p_w1b},#{@p_w1c},#{@p_w1d},#{@p_w2},#{@p_w4a},#{@p_w4b}"
    QUERY
    
    combined_command = command + ' ' + @qry
    combined_command.gsub!(/\n/,' ')

    File.open('mtp_project_out.txt', 'a') {|file| file.write("\n#{combined_command}\n")}

    `#{combined_command}`

    #puts @prioritization_qry

    puts "Added project #{mtpid} to staging tables."
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
    projects = []
    item_nodes.each do |node|
      proj = PlanProject.new(node)
      projects<< proj
    end
    projects
  end
end

class ImportFile
  
  def initialize(filepath)
    submissions = Submissions.new(filepath)
    projects = submissions.parse
    send_to_db(projects)
  end
  
  def send_to_db(projects)
    # import each project in projects to the db
    projects.each do |project|
      project.send_to_db
    end 
  end 
  
  
end 


mtp_submissions = Submissions.new('mtp_projects.xml'); nil;
p = mtp_submissions.parse; nil;
p.each {|project| project.send_to_db}
#puts p[0].qry
