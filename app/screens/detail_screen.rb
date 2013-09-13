class DetailScreen < PM::TableScreen

  attr_accessor :container, :data, :date

  def on_load
    @data.sort! {|a,b| a.sort_by <=> b.sort_by }
  end

  def will_appear
    Flurry.logEvent "DetailScreen" unless Device.simulator?
    @view_setup ||= begin
      self.setTitle("Details", subtitle:"for #{@date}")
      self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle = UIBarStyleBlack if Device.ios_version.to_f < 7.0
      self.navigationController.setToolbarHidden(false)

      #Create the labe at the bottom of the view.
      @label = set_attributes UILabel.alloc.initWithFrame(CGRectMake(0, 0, self.navigationController.toolbar.bounds.size.width, self.navigationController.toolbar.bounds.size.height)), {
        background_color: UIColor.clearColor,
        text_color: (Device.ios_version.to_f < 7.0 ? UIColor.whiteColor : "#0F5D14".to_color),
        text_alignment: UITextAlignmentCenter,
        line_break_mode: UILineBreakModeTailTruncation,
        font: UIFont.boldSystemFontOfSize(18),
        minimum_font_size: 10,
        resize: [:width, :left, :right],
        text: "#{count('incident')} Incidents & #{count('arrest')} Arrests"
      }
      item = UIBarButtonItem.alloc.initWithCustomView(@label)
      self.toolbarItems = [item]

      # Done Button
      set_nav_bar_button :right,
        title: "Close",
        action: :close,
        type: UIBarButtonItemStyleDone

      update_table_data
    end
  end

  def table_data
    [{
      title: "Arrests",
      cells: build_cells(:arrest)
    }, {
      title: "Incidents",
      cells: build_cells(:incident)
    }]
  end

  def build_cells(type)
    c = []
    crimes = type == :arrest ? arrests : incidents
    crimes.each_with_index do |cell,i|
      c << {
        title: cell.title,
        cell_style: UITableViewCellStyleSubtitle,
        subtitle: cell.subtitle,
        selection_style: UITableViewCellSelectionStyleBlue,
        accessory_type: UITableViewCellAccessoryDisclosureIndicator,
        accessory_action: :tapped_crime,
        action: :tapped_crime,
        arguments: {marker_index: i, marker_type: type}
      }
    end
    c
  end

  def arrests
    @data.select { |crime| crime.type.downcase == 'arrest' }
  end

  def incidents
    @data.select { |crime| crime.type.downcase == 'incident' }
  end

  def tapped_crime(params = {})
    crimes = params[:marker_type] == :arrest ? arrests : incidents
    marker = crimes[params[:marker_index]]

    Flurry.logEvent "TappedCrimeDetail" unless Device.simulator?

    @container.closeDetailAndZoomToEvent(marker) unless @container.nil?
  end

  def count(type)
    @data.select { |crime| crime.type.downcase == type.downcase }.count
  end

end
