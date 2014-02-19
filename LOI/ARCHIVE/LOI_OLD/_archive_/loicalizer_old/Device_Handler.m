% 10/09/2012 JMT Add handler for Windows XP

chosen_device = [];

switch upper(computer)
  
  case 'MACI64'
    
    numDevices=PsychHID('NumDevices');
    devices=PsychHID('Devices');
    candidate_devices = [];
    top_candidate = [];
    
    % probe_string='Searching for Devices ...';
    % fprintf('%s\n',probe_string)
    
    for n=1:numDevices,
      if (~(isempty(findstr(devices(n).transport,'USB'))) || ~isempty(findstr(devices(n).usageName,'Keyboard')))
        disp(sprintf('Device #%d is a potential input device [%s, %s]\n',n,devices(n).usageName,devices(n).product))
        candidate_devices = [candidate_devices n];
        if (devices(n).productID==16385 | devices(n).vendorID==6171 | devices(n).totalElements==274)
          top_candidate = n;
        end
      end
    end
    
    prompt_string = sprintf('Which device for responses (%s)? ', num2str(candidate_devices));
    
    if ~isempty(top_candidate)
      prompt_string = sprintf('%s [Enter for %d]', prompt_string, top_candidate);
    end
    
    while isempty(chosen_device)
      chosen_device = input(prompt_string);
      if isempty(chosen_device) & ~isempty(top_candidate)
        chosen_device = top_candidate;
      elseif isempty(find(candidate_devices == chosen_device))
        fprintf('Invalid Response!\n')
        chosen_device = [];
      end
    end
    
  case {'PCWIN','PCWIN64'}
    
    % Do nothing for now - return empty chosen_device
    % Windows XP merges keyboard input and will process external keyboards
    % such as the Silver Box correctly
 
  otherwise
    
    % Do nothing - return empty chosen_device
    
end