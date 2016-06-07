function [ m_0_1 ] = remove_single_1_0( m_0_1 )
%REMOVE_SINGLE_1_0 Summary of this function goes here
%   Detailed explanation goes here

n = size(m_0_1);
n = n(2);



for i = 2:(n-1)
    
    if m_0_1(i-1)==0 && m_0_1(i+1)==0 && m_0_1(i)==1
        m_0_1(i) = 0;
    end
        
    if m_0_1(i-1)==1 && m_0_1(i+1)==1 && m_0_1(i)==0
        m_0_1(i) = 1;
    end
        
end

end
