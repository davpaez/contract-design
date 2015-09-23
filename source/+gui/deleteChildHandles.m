function deleteChildHandles(h)
% Deletes child handles from h
    
    child_handles = allchild(h);
    
    for i=1:length(child_handles)
        h = child_handles(i);
        delete(h);
    end
end