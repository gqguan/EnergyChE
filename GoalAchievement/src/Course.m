classdef Course
    %课程信息
    %   此处显示详细说明
    
    properties
        ReleaseYear = ""
        Code = ""
        Title = ""
        Category = ""
        CompulsoryOrNot = true
        ClassHour = []
        Credits = ""
        Semester = ""
        Institute = "化学与化工学院"
        ProgramOriented = "能源化学工程"
        Language = "中文"
        Prerequisites = {}
        Outcomes = {}
        Objectives = {}
        Description = ""
        Content = ""
        ExpDetail = {}
        ExpTeach = ""
        TeachMethod = ""
        ExamMethod = ""
        Benchmark = {}
        Notices = ""
        Textbook = ""
        FilePath = ""
        LogInfo = ""
    end
    
    methods
        function obj = Course(inputArg)
            %Course 构造此类的实例
            %   构造课程对象，需指明课程名称
            if exist('inputArg','var')
                if isa(inputArg,'Course')
                    obj = inputArg;
                elseif ischar(inputArg) || isstring(inputArg)
                    obj.Title = string(inputArg);
                else
                    error('课程名称指定有误')
                end
            else
                error('未指定课程名称')
            end
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 此处显示有关此方法的摘要
%             %   此处显示详细说明
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

