#!/usr/bin/env ruby

class Project
  attr_accessor :username, :project_name, :file_name

  def initialize (username, project_name, file_name)
    @username = username
    @project_name = project_name
    @file_name = file_name
  end
end

