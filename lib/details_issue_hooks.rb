class DetailsIssueHooks < Redmine::Hook::ViewListener

  def protect_against_forgery?
    false
  end

  def current_is_detail_page(context)
    # check if we see an issue but not creating a new one or on the specific edit page
    ret = context[:controller] && context[:controller].is_a?(IssuesController) && context[:request].original_url.rindex(/\/issues\/\S+/) && !context[:request].original_url.rindex(/\/issues\/new/) && !context[:request].original_url.rindex(/\/issues\/\d+\/edit/)
  end

  def view_layouts_base_html_head(context)
    return unless current_is_detail_page(context)

    is_disable_dynamic = User.current.custom_field_values.find{ |field| field.custom_field.name == 'Disable Issue Dynamic Edit' }

    if is_disable_dynamic.to_s != "1" && User.current.allowed_to?(:edit_issues, context[:project])
      stylesheet_link_tag('issue_dynamic_edit.css', :plugin => :redmine_issue_dynamic_edit)
    end
    
  end

  def view_layouts_base_body_bottom(context)
    return unless current_is_detail_page(context)
    
    is_disable_dynamic = User.current.custom_field_values.find{ |field| field.custom_field.name == 'Disable Issue Dynamic Edit' }
        
    if is_disable_dynamic.to_s != "1" && User.current.allowed_to?(:edit_issues, context[:project])
      javascript_include_tag('issue_dynamic_edit_configuration_file.js', 'issue_dynamic_edit.js', :plugin => :redmine_issue_dynamic_edit)
    end
    
  end

  def view_issues_show_details_bottom(context)
    content = "<script>\n"
    content << " const _ISSUE_ID = \"#{context[:request].path_parameters[:id]}\";\n"
    content << " const _PROJECT_ID = \"#{Issue.find(context[:request].path_parameters[:id]).project_id}\";\n"
    content << " const _TXT_CONFLICT_TITLE = \"" + l(:ide_txt_notice_conflict_title) + "\";\n"
    content << " const _TXT_CONFLICT_TXT = \"" + l(:ide_txt_notice_conflict_text) + "\";\n"
    content << " const _TXT_CONFLICT_LINK = \"" + l(:ide_txt_notice_conflict_link) + "\";\n"
    content << "</script>\n"
    content << "<style>/* PRINT MEDIAQUERY */\n"
    content << "@media print {\n"
    content << "body.controller-issues.action-show div.issue.details .subject .refreshData,\n"
    content << "body.controller-issues.action-show div.issue.details .iconEdit,\n"
    content << "body.controller-issues.action-show .dynamicEditField {\n"
    content << "display : none !important;\n"
    content << "height: 0;\n"
    content << "width: 0;\n"
    content << "overflow: hidden;\n"
    content << "padding : 0;\n"
    content << "margin: 0;\n"
    content << "}\n"
    content << "}</style>\n"
    return content.html_safe
  end

end
