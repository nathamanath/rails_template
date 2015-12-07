module FormsHelper
  # Display list of validation errors for form
  # example: `= form_errors(@object)`
  def form_errors(object)
    if object.errors.any?
      content_tag(:section, id: 'form-errors', class: 'form-errors') do
        content_tag(:ul, class: 'form-errors-list') do
          content = '';

          object.errors.full_messages.each do |error|
            content += content_tag(:li, class: 'form-errors-item') do
              error
            end
          end

          content.html_safe
        end
      end
    end
  end
end
