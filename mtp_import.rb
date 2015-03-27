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
    @description = c.css('description').first.content
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
    @func_class_id = c.css('functional-class').first.content.empty? ? 'NULL' : c.css('functional-class').first.content
    @start_year = c.css('start-year').first.content
  end
  
  def send_to_db
    #create an input query and fire it off to SQL Server via shell command
    command = <<-COMMAND
    SQLCMD -S SQL2008\\\PSRCSQL -E -d MTPData_dev -Q 
    COMMAND


    @qry = <<-QUERY 
    "INSERT INTO tblStageProject (MTPID, Title, ProjDesc, TotProjCost,
    ContactName, ContactPhone, ContactEmail, EstCostYear,
    CompletionYear, MTPStatus, ProjectOn, ProjectFrom,
    ProjectTo, MilePostFrom, MilePostTo, FuncClassiD,
    StartYear)
    VALUES (#{@mtpid},'#{@title}','#{@description}',#{@tot_proj_cost},
    '#{@contact_name}','#{@contact_phone}','#{@contact_email}',#{@est_cost_year},
    #{@completion_year},#{@mtp_status},'#{@project_on}','#{@project_from}',
    '#{@project_to}',#{@mile_post_from},#{@mile_post_to},#{@func_class_id},
    #{@start_year})"
    QUERY
    
    combined_command = command + ' ' + @qry

    combined_command.gsub!(/\n/,' ')

    #combined_command.gsub!(/,,,/,',NULL,NULL,')
    
    #puts combined_command
    #3.times {puts ""}
    File.open('mtp_project_out.txt', 'a') {|file| file.write("\n#{combined_command}\n")}

    `#{combined_command}`
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
      #puts "node class = #{node.class}"
      proj = PlanProject.new(node)
      #projects<< node
      #projects<< node.children.css('project-id')
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
