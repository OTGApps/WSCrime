class DetailScreen < PM::TableScreen

  attr_accessor :parentVC, :data, :date

  def on_load
    @data.sort! {|a,b| a.annotation_params[:sort_by] <=> b.annotation_params[:sort_by] }
  end

  def will_appear
    @view_setup ||= begin
      self.setTitle("Details", subtitle:"for #{@date}")
      self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle = UIBarStyleBlack
      self.navigationController.setToolbarHidden(false)

      #Create the labe at the bottom of the view.
      @label = set_attributes UILabel.alloc.initWithFrame(CGRectMake(0, 0, self.navigationController.toolbar.bounds.size.width, self.navigationController.toolbar.bounds.size.height)), {
        background_color: UIColor.clearColor,
        text_color: UIColor.whiteColor,
        text_alignment: UITextAlignmentCenter,
        line_break_mode: UILineBreakModeTailTruncation,
        font: UIFont.boldSystemFontOfSize(18),
        minimum_font_size: 10,
        resize: [:width, :left, :right],
        text: "#{incidentCount} Incidents & #{arrestCount} Arrests"
      }
      item = UIBarButtonItem.alloc.initWithCustomView(@label)
      self.toolbarItems = [item]

      # Done Button
      set_nav_bar_button :right,
        title: "Done",
        action: :close_modal,
        type: UIBarButtonItemStyleDone

      update_table_data
    end
  end

  def table_data
    [{cells:build_cells}]
  end

  def build_cells
    c = []
    @data.each_with_index do |cell,i|
      c << {
        title: cell.title,
        cell_style: UITableViewCellStyleSubtitle,
        subtitle: cell.subtitle,
        selection_style: UITableViewCellSelectionStyleBlue,
        accessory_type: UITableViewCellAccessoryDetailDisclosureButton,
        accessory_action: :tapped_crime,
        action: :tapped_crime,
        arguments: {marker_index: i},
        image: pin_image(cell)
      }
    end
    c
  end

  def pin_image(cell)
    cell.annotation_params[:type].downcase == "arrest" ? "pinannotation_red" : "pinannotation_purple"
  end

  def tapped_crime(params = {})
    @parentVC.closeDetailAndZoomToEvent(@data[params[:marker_index]]) unless @parentVC.nil?
  end

  def incidentCount
    @data.select { |crime| crime.annotation_params[:type] == "Incident" }.count
  end

  def arrestCount
    @data.select { |crime| crime.annotation_params[:type] == "Arrest" }.count
  end

  def close_modal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

end
