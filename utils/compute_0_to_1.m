function [ result ] = compute_0_to_1( m_0_1 )
%COMPUTE_0_TO_1 Summary of this function goes here
%   Detailed explanation goes here
n = size(m_0_1);
n = n(2);

result = m_0_1;

for i = 2:(n-1)    
    
    if m_0_1(i-1)==0 && m_0_1(i)==1
        result(i) = 1;
    else
        result(i) = 0;        
    end
        
end

end

