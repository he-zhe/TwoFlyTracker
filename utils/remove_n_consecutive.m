function [ m_0_1 ] = remove_n_consecutive( m_0_1, n )
%REMOVE_SINGLE_1_0 Summary of this function goes here
%   Detailed explanation goes here

sz = size(m_0_1);
sz = sz(2);



    for i = 1:sz - n -1

    for j = 2:n+1

    if m_0_1(i)==1 && m_0_1(i+j)==1 && all(m_0_1(i+1:i+j-1))==0
                        m_0_1(i+1:i+j-1)= 1;
    end
    end
    end
    for i = 1:sz - n -1

    for j = 2:n+1
    if m_0_1(i)==0 && m_0_1(i+j)==0 && all(m_0_1(i+1:i+j-1))==1
                        m_0_1(i+1:i+j-1)= 0;
    end
    end
    end