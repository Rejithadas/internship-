select distinct post_type 
from fact_content;

select post_type,max(impressions) as highest_impression , min(impressions) as lowest_impression 
from fact_content
group by post_type;

select 
f.date,post_category,post_type,video_duration,carousel_item_count,
impressions,reach,shares,follows,likes,comments,saves
from fact_content as f
left join dim_dates d  
on f.date=d.date
where weekday_or_weekend='Weekend' and month_name in ('March','April');

select month_name,sum(profile_visits) as total_profile_visits,sum(new_followers) as total_new_followers
from fact_account as f 
left join dim_dates d 
on f.date=d.date
group by month_name ;


select post_category,sum(likes) as total_likes 
from fact_content
where monthname(date)='July'
group by post_category;

with cte as ( 
select post_category,sum(likes) as total_likes 
from fact_content
where monthname(date)='July' 
group by post_category )
select post_category, total_likes 
from cte 
order by total_likes desc ;

select 
monthname(date) as month_name , 
group_concat(distinct post_category order by post_category separator ',') as post_category, 
count(distinct post_category) as post_category_count
from  fact_content
group by month_name;

with cte as ( 
select sum(reach) as grand_total_reach from fact_content)
select post_type,
sum(reach) as total_reach,
round(sum(reach)/(select grand_total_reach from cte )*100,2) as reach_percentage
from fact_content
group by post_type
order by reach_percentage desc;

select post_category,
case 
when monthname(date) in ('January','February','March') then 'Q1'
when monthname(date) in ('April','May','June') then 'Q2'
when monthname(date) in ('July','August','September') then 'Q3'end as quarter,
sum(comments) as total_comments, 
sum(saves) as total_saves
from fact_content
group by post_category,quarter;

with cte as ( select 
	monthname(date) as month,
	date, new_followers,dense_rank() over(partition by monthname(date) order by new_followers desc) as rn 
from fact_account )
select month,date,new_followers
from cte where rn<=3;


DELIMITER //
create procedure post_shares_by_Weekno
(
	in_week_no int
)
begin 
	select post_type,sum(shares) as total_shares 
	from fact_content f
	join dim_dates d 
	on f.date=d.date
	where week_no=in_week_no
	group by post_type;
end

