function [ output_args ] = report_single( input_args )

    hpanel4 = findobj('Tag', 'panel4');
    data = getappdata(hpanel4, 'reportSingle');
    gui.plotRealization()
    
end

