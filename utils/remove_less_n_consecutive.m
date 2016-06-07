function [ m_0_1 ] = remove_less_n_consecutive( m_0_1 , m)
%REMOVE_SINGLE_1_0 Summary of this function goes here
%   Detailed explanation goes here

n = size(m_0_1);
n = n(2);

i = 2;

while i<=n-m
    if m_0_1(i-1) == 0 && m_0_1(i) == 1 && ~all(m_0_1(i+1:i+m))
        m_0_1(i) = 0;
    end
    i = i+1;
end




end
